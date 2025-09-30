"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
import os
import sys
import yaml
from textwrap import dedent


def main():
    # NOTE: The order is important. Filepaths must be resolved before config is
    # written, otherwise augur subsample will not work.
    resolve_filepaths([
        ("subsample", "*", "samples", "*", "include"),
        ("subsample", "*", "samples", "*", "exclude"),
        ("subsample", "*", "samples", "*", "group_by_weights"),
        ("custom_subsample", "*", "samples", "*", "include"),
        ("custom_subsample", "*", "samples", "*", "exclude"),
        ("custom_subsample", "*", "samples", "*", "group_by_weights"),
    ])
    write_config("results/run_config.yaml")


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


def write_config(path):
    """
    Write Snakemake's 'config' variable to a file.

    This is used for the subsample rule and is generally useful for debugging.
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)

    with open(path, 'w') as f:
        yaml.dump(config, f, sort_keys=False)

    print(f"Saved current run config to {path!r}.", file=sys.stderr)


main()
