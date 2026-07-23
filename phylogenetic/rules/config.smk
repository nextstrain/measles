"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
    results/{build}/subsample_config.yaml
"""
from augur.subsample import merge_defaults

def get_gene(build: str) -> str:
    """Extract the gene from a multi-part build string (e.g. 'genome/global' -> 'genome')."""
    return build.split("/")[0]


def main():
    normalize_config()
    validate_config()
    write_subsample_config()
    write_config("results/run_config.yaml")


def normalize_config():
    # Normalize scalar string to a single-item list
    if isinstance(config['builds'], str):
        config['builds'] = [config['builds']]


def validate_config():
    """
    Validate the config.

    This could be improved with a schema definition file, but for now it serves
    to provide useful error messages for common user errors and effects of
    breaking changes.
    """
    # Config keys whose value must be a dict keyed by build name, with one entry
    # for each build listed in config.builds. (Extra values are allowed so that
    # you can specify a custom subset of builds via --config or similar.)
    per_build_keys = ["refine", "traits", "export"]
    # TODO: use the other helper functions to do validation on these keys and
    # support extended syntax (currently only applies to subsample).
    # This can be done alongside the larger effort to use file-based
    # configuration for these keys instead of reading directly from `config`.

    builds = set(config["builds"])

    for key in per_build_keys:
        if key not in config:
            raise InvalidConfigError(f"Config must define a 'config.{key}' section")

        value = config[key]
        if not isinstance(value, dict):
            raise InvalidConfigError(
                f"Config 'config.{key}' must be a dict keyed by build name, "
                f"but it is a {type(value).__name__}"
            )

        missing_builds = builds - set(value)
        if len(missing_builds):
            raise InvalidConfigError(
                f"The keys of 'config.{key}' must contain all requested builds; "
                f"you are currently missing ({', '.join(sorted(missing_builds))})"
            )

    # gene wildcard values must be present in the nextclade config entry
    if not isinstance(config['nextclade'], dict):
        raise InvalidConfigError(
            f"Config 'config.nextclade' must be a dict but it is a {type(config['nextclade']).__name__}"
        )
    missing_gene_vals = set([get_gene(build) for build in config["builds"]]) - set(config['nextclade'].keys())
    if len(missing_gene_vals):
        raise InvalidConfigError(
            f"The keys of 'config.nextclade' must contain all necessary 'gene' values; "
            f"you are currently missing ({', '.join(sorted(missing_gene_vals))})"
        )



def write_subsample_config():
    """
    Generate and write the subsample config files for all builds.

    Performs validation, resolves pattern-based configs for each build, applies
    post-processing (merging subsample defaults), and writes the fully resolved configs.
    """
    validate_rule_configs(config, ["subsample"], config["builds"])

    for build in config["builds"]:
        # Three different merges happen in the following order:
        # 1. Snakemake's built-in config merging
        #    Already done at this point, `config` is the result.

        # 2. Merge across matching build patterns
        subsample_config = resolve_rule_config(config, "subsample", build)

        # 3. Merge defaults into sample-specific options
        #    augur subsample can do this automatically, but it's done here for explicitness in the output subsample config.
        subsample_config = merge_defaults(subsample_config)

        write_rule_config(f"results/{build}/subsample_config.yaml", subsample_config, build)



# The following functions handle multi-build workflow configuration (glob
# syntax → small multiples).
# TODO: Move these to shared/vendored/snakemake/config.smk after testing in this
# repo for some time.

import copy
import re
from typing import Any, Optional


def validate_rule_configs(
    config: dict,
    rule_names: list[str],
    builds: list[str],
) -> None:
    """
    Validate rule configuration blocks.
    """
    for rule_name in rule_names:
        custom_key = f"custom_{rule_name}"
        block_key = custom_key if custom_key in config else rule_name

        if block_key not in config:
            raise InvalidConfigError(
                f"Config must define a 'config.{rule_name}' section"
            )

        block = config[block_key]
        # Verify rule configuration block is a dictionary
        if not isinstance(block, dict):
            raise InvalidConfigError(
                f"Config 'config.{block_key}' must be a dict keyed by build pattern, "
                f"but it is a {type(block).__name__}"
            )

        # Verify every build is matched by at least one pattern
        unmatched = [
            build for build in builds
            if not any(_match_pattern(str(p), build) for p in block)
        ]
        if unmatched:
            raise InvalidConfigError(
                f"The following builds are not matched by any pattern in "
                f"'config.{block_key}': {', '.join(sorted(unmatched))}"
            )


def resolve_rule_config(
    config: dict,
    rule_name: str,
    build: str,
) -> Optional[dict]:
    """
    Resolve the configuration for a single rule and build by matching
    patterns and merging in definition order.

    Uses ``custom_<rule_name>`` if present, otherwise ``rule_name``.
    Returns the merged config dict (or None if the resolved value is False).
    """
    # Check for custom overrides
    block_key = f"custom_{rule_name}" if f"custom_{rule_name}" in config else rule_name
    block = config[block_key]

    # Merge matching configurations sequentially
    result = None
    for pattern, pattern_config in block.items():
        if _match_pattern(str(pattern), build):
            # False deletes
            if pattern_config is False:
                result = None

            # Empty is not allowed
            elif pattern_config is None:
                raise InvalidConfigError(
                    f"'config.{rule_name}.{pattern}' is empty. "
                    "Check for typos, or use 'False' to explicitly skip/delete."
                )

            # Initial assignment
            elif result is None:
                result = copy.deepcopy(pattern_config) if isinstance(pattern_config, dict) else pattern_config

            # Dicts are merged
            else:
                result = _merge_configs(result, pattern_config)

    return result


def write_rule_config(
    path: str,
    data: dict,
    build: str,
) -> None:
    """
    Write a resolved rule config to a YAML file with a build header comment.

    This creates a fully resolved config file corresponding to the rule's command schema,
    allowing users to copy-paste the resolved baseline directly back into their top-level
    config to adjust parameters.
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(f"# {build}\n")
        yaml.dump(data, f, sort_keys=False, Dumper=NoAliasDumper)
    print(f"Saved config for '{build}' to {path!r}.", file=sys.stderr)


def _match_pattern(
    pattern: str,
    build: str,
) -> bool:
    """
    Check if a build pattern matches a concrete build name.

    *pattern* and *build* are slash-delimited strings.

    Supports literal, wildcard (*), and multivalue ((a|b)) pattern parts.
    """
    pattern_parts = pattern.split("/")
    build_parts = build.split("/")

    if len(pattern_parts) != len(build_parts):
        return False

    for pattern_part, build_part in zip(pattern_parts, build_parts):
        # Wildcard syntax: matches any value at this level
        if pattern_part == "*":
            continue

        # Multivalue syntax: matches any of the pipe-separated values inside parentheses
        if multivalue := re.fullmatch(r'\(([^)]+)\)', pattern_part):
            values = multivalue.group(1).split("|")
            if build_part not in values:
                return False
        # Literal syntax: matches the specified string exactly
        elif pattern_part != build_part:
            return False

    return True


def _merge_configs(
    base: Any,
    override: Any,
) -> Any:
    """
    Merge *override* config on top of *base* config.

    Behavior is consistent with Snakemake: dicts are merged, scalars and lists
    override.
    """
    merged = copy.deepcopy(base)
    for key, value in override.items():
        # Null deletes
        if value is None:
            merged.pop(key, None)

        # Dicts are merged
        elif isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = _merge_configs(merged[key], value)

        # Scalars and lists override
        else:
            merged[key] = copy.deepcopy(value)
    return merged


try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
