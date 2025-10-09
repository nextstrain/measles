"""
Shared functions to be used within a Snakemake workflow for handling
workflow configs.
"""
import os
import sys
import yaml
from collections.abc import Callable
from copy import deepcopy
from itertools import product
from snakemake.io import Wildcards
from typing import Optional
from textwrap import dedent, indent


class InvalidConfigError(Exception):
    pass


def resolve_filepaths(filepaths):
    """
    Update filepaths in-place by passing them through resolve_config_path().

    `filepaths` must be a list of key tuples representing filepaths in config.
    Use "*" as a a key-expansion placeholder: it means "iterate over all keys at
    this level".
    """
    global config

    for keys in filepaths:
        _traverse(config, keys, traversed_keys=[])


def _traverse(config_section, keys, traversed_keys):
    """
    Recursively walk through the config following a list of keys.

    When the final key is reached, the value is updated in place.
    """
    key = keys[0]
    remaining_keys = keys[1:]

    if key == "*":
        for key in config_section:
            if len(remaining_keys) == 0:
                _update_value_inplace(config_section, key, traversed_keys=traversed_keys + [f'* ({key})'])
            else:
                if isinstance(config_section[key], dict):
                    _traverse(config_section[key], remaining_keys, traversed_keys=traversed_keys + [f'* ({key})'])
                else:
                    # Value for key is not a dict
                    # Leave as-is - this may be valid config value.
                    continue
    elif key in config_section:
        if len(remaining_keys) == 0:
            _update_value_inplace(config_section, key, traversed_keys=traversed_keys + [key])
        else:
            _traverse(config_section[key], remaining_keys, traversed_keys=traversed_keys + [key])
    else:
        # Key not present in config section
        # Ignore - this may be an optional parameter.
        return


def _update_value_inplace(config_section, key, traversed_keys):
    """
    Update the value at 'config_section[key]' with resolve_config_path().

    resolve_config_path() returns a callable which has the ability to replace
    {var} in filepath strings. This was originally designed to support Snakemake
    wildcards, but those are not applicable here since this code is not running
    in the context of a Snakemake rule. It is unused here - the callable is
    given an empty dict.
    """
    value = config_section[key]
    traversed = ' → '.join(repr(key) for key in traversed_keys)
    if isinstance(value, list):
        for path in value:
            assert isinstance(path, str), f"ERROR: Expected string but got {type(path).__name__} at {traversed}."
        new_value = [resolve_config_path(path)({}) for path in value]
    else:
        assert isinstance(value, str), f"ERROR: Expected string but got {type(value).__name__} at {traversed}."
        new_value = resolve_config_path(value)({})
    config_section[key] = new_value
    print(f"Resolved {value!r} to {new_value!r}.", file=sys.stderr)


def resolve_config_path(path: str, defaults_dir: Optional[str] = None) -> Callable[[Wildcards], str]:
    """
    Resolve a relative *path* given in a configuration value. Will always try to
    resolve *path* after expanding wildcards with Snakemake's `expand` functionality.

    Returns the path for the first existing file, checked in the following order:
    1. relative to the analysis directory or workdir, usually given by ``--directory`` (``-d``)
    2. relative to *defaults_dir* if it's provided
    3. relative to the workflow's ``defaults/`` directory if *defaults_dir* is _not_ provided

    This behaviour allows a default configuration value to point to a default
    auxiliary file while also letting the file used be overridden either by
    setting an alternate file path in the configuration or by creating a file
    with the conventional name in the workflow's analysis directory.
    """
    global workflow

    def _resolve_config_path(wildcards):
        try:
            expanded_path = expand(path, **wildcards)[0]
        except snakemake.exceptions.WildcardError as e:
            available_wildcards = "\n".join(f"  - {wildcard}" for wildcard in wildcards)
            raise snakemake.exceptions.WildcardError(indent(dedent(f"""\
                {str(e)}

                However, resolve_config_path({{path}}) requires the wildcard.

                Wildcards available for this path are:

                {{available_wildcards}}

                Hint: Check that the config path value does not misspell the wildcard name
                and that the rule actually uses the wildcard name.
                """.lstrip("\n").rstrip()).format(path=repr(path), available_wildcards=available_wildcards), " " * 4))

        if os.path.exists(expanded_path):
            return expanded_path

        if defaults_dir:
            defaults_path = os.path.join(defaults_dir, expanded_path)
        else:
            # Special-case defaults/… for backwards compatibility with older
            # configs.  We could achieve the same behaviour with a symlink
            # (defaults/defaults → .) but that seems less clear.
            if path.startswith("defaults/"):
                defaults_path = os.path.join(workflow.basedir, expanded_path)
            else:
                defaults_path = os.path.join(workflow.basedir, "defaults", expanded_path)

        if os.path.exists(defaults_path):
            return defaults_path

        raise InvalidConfigError(indent(dedent(f"""\
            Unable to resolve the config-provided path {path!r},
            expanded to {expanded_path!r} after filling in wildcards.
            The workflow does not include the default file {defaults_path!r}.

            Hint: Check that the file {expanded_path!r} exists in your analysis
            directory or remove the config param to use the workflow defaults.
            """), " " * 4))

    return _resolve_config_path


def write_config(path):
    """
    Write Snakemake's 'config' variable to a file.
    """
    global config

    os.makedirs(os.path.dirname(path), exist_ok=True)

    with open(path, 'w') as f:
        yaml.dump(config, f, sort_keys=False)

    print(f"Saved current run config to {path!r}.", file=sys.stderr)


def process_subsample_config():
    """
    Process the subsample config to expand matrix format into nested dicts.

    If config['subsample'] contains 'defaults' and 'matrix' keys, expands
    the N-dimensional matrix into config['subsample'][dim1][dim2]...[dimN].

    Merge order: defaults → dim1[v1] → dim2[v2] → ... → dimN[vN] → samples[s]
    """
    if not isinstance(config.get("subsample"), dict):
        # Old format (string path) or not present, skip processing
        return

    subsample_config = config["subsample"]

    if "defaults" not in subsample_config or "matrix" not in subsample_config:
        # Already expanded or different format, skip processing
        return

    defaults = subsample_config.get("defaults", {})
    matrix = subsample_config["matrix"]

    # Derive dimensions from matrix keys
    # Dimension names = top-level keys under matrix
    # Dimension values = nested keys under each dimension
    dimensions = {dim_name: list(dim_values.keys())
                  for dim_name, dim_values in matrix.items()}

    # Get dimension names and values in order
    dim_names = list(dimensions.keys())
    dim_values = [dimensions[name] for name in dim_names]

    # Build expanded config
    expanded = {}

    # Generate all combinations via Cartesian product
    for combination in product(*dim_values):
        # Create context dict mapping dimension names to values
        # e.g., {build: "genome", resolution: "6y"}
        context = dict(zip(dim_names, combination))

        # Start with defaults
        merged_params = deepcopy(defaults) if defaults else {}

        # Apply dimension-specific parameters in order
        for dim_name in dim_names:
            dim_value = context[dim_name]

            if dim_name in matrix and dim_value in matrix[dim_name]:
                dim_specific = matrix[dim_name][dim_value]

                # Check if this dimension defines samples
                if dim_specific and "samples" in dim_specific:
                    # This dimension provides sample definitions
                    # We'll handle this separately below
                    pass
                else:
                    # Regular parameters to merge
                    merged_params = merge_dicts(merged_params, dim_specific)

        # Determine which samples to use
        # Priority: last dimension with samples > earlier dimensions with samples
        samples_to_use = None
        for dim_name in reversed(dim_names):  # Check in reverse order for highest priority
            dim_value = context[dim_name]
            if dim_name in matrix and dim_value in matrix[dim_name]:
                dim_specific = matrix[dim_name][dim_value]
                if dim_specific and "samples" in dim_specific:
                    samples_to_use = dim_specific["samples"]
                    break

        # If no samples found, use empty dict with single "global" sample
        if samples_to_use is None:
            samples_to_use = {"global": {}}

        # Build the samples section
        samples = {}
        for sample_name, sample_params in samples_to_use.items():
            # Merge: merged_params (defaults + all dimensions) → sample-specific
            merged = merge_dicts(merged_params, sample_params)
            samples[sample_name] = merged

        # Create output config
        output_config = {"samples": samples}

        # Store in nested dict structure using dimension values as keys
        keys = [context[dim_name] for dim_name in dim_names]
        set_nested_dict(expanded, keys, output_config)

    # Replace subsample config with expanded version
    config["subsample"] = expanded

    print(f"Expanded subsample config matrix into {len(list(product(*dim_values)))} configurations.", file=sys.stderr)


def merge_dicts(*dicts):
    """Merge multiple dictionaries, with later values overriding earlier ones."""
    result = {}
    for d in dicts:
        if d is not None:
            # Deep copy to ensure nested structures aren't shared
            result.update(deepcopy(d))
    return result


def set_nested_dict(d, keys, value):
    """Set a value in a nested dict at arbitrary depth."""
    for key in keys[:-1]:
        if key not in d:
            d[key] = {}
        d = d[key]
    d[keys[-1]] = value
