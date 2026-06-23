"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
import copy
import os
import sys
import yaml
from itertools import product
from textwrap import dedent
from typing import Any, Literal, TypedDict


VALID_DATASET_LEVELS = [
    {"name": "gene", "values": ["genome", "N450"]},
    {"name": "region", "values": ["global", "north-america"]},
]

YAML_CONFIGURED_RULES = [
    "subsample",
    "refine",
]

def main():
    normalize_config()
    validate_config()
    datasets = [build.split("/") for build in config["builds"]]
    for rule_name in YAML_CONFIGURED_RULES:
        write_command_configs(config, rule_name, datasets, "results")
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
    per_build_keys = ["traits", "export"]

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
            f"Config 'config.nextclade' must be a dict but it is a {type(value).__name__}"
        )
    missing_gene_vals = set([build.split("/")[0] for build in config["builds"]]) - set(config['nextclade'].keys())
    if len(missing_gene_vals):
        raise InvalidConfigError(
            f"The keys of 'config.nextclade' must contain all necessary 'gene' values; "
            f"you are currently missing ({', '.join(sorted(missing_gene_vals))})"
        )

    for rule_name in YAML_CONFIGURED_RULES:
        if rule_name in config:
            validate_rule_config(rule_name, config[rule_name], VALID_DATASET_LEVELS)
        override = rule_override_name(rule_name)
        if override in config:
            validate_rule_config(override, config[override], VALID_DATASET_LEVELS)


# FIXME: everything below is independent of VALID_DATASET_LEVELS/DATASET_LEVELS_TO_RUN and can be moved to shared/vendored/config.smk or Augur

ExactDataset = tuple[str, ...]
"""Exact dataset values, ordered to match VALID_DATASET_LEVELS."""

class DatasetPatternPart(TypedDict):
    type: Literal["wildcard", "literal", "multivalue"]
    matches: tuple[str, ...] | None


class DatasetLevel(TypedDict):
    name: str
    values: list[str]


def validate_rule_config(
    rule_name: str,
    rule_config: dict[str, Any],
    dataset_levels: list[DatasetLevel],
) -> None:
    if not isinstance(rule_config, dict):
        raise InvalidConfigError(f"'{rule_name}' must be a mapping of dataset patterns to config layers.")

    for pattern, config_layer in rule_config.items():
        if not isinstance(pattern, str):
            raise InvalidConfigError(f"{rule_name} pattern {pattern!r} must be a string.")
        _validate_dataset_pattern(pattern, dataset_levels, rule_name)

        if not isinstance(config_layer, dict):
            raise InvalidConfigError(f"{rule_name} config for pattern {pattern!r} must be a mapping.")


def _validate_dataset_pattern(
    pattern: str,
    dataset_levels: list[DatasetLevel],
    context: str,
) -> None:
    pattern_parts = parse_dataset_pattern(pattern)
    if len(pattern_parts) != len(dataset_levels):
        raise InvalidConfigError(dedent(f"""\
            Invalid {context} dataset pattern {pattern!r}.
            Expected {len(dataset_levels)} slash-separated parts matching:
                {'/'.join(level['name'] for level in dataset_levels)}"""))

    for pattern_part, level in zip(pattern_parts, dataset_levels):
        if pattern_part["type"] == "wildcard":
            continue

        invalid_values = sorted(set(pattern_part["matches"]) - set(level["values"]))
        if invalid_values:
            raise InvalidConfigError(dedent(f"""\
                Invalid {context} dataset value(s) {invalid_values!r} in pattern {pattern!r}.
                Expected {level['name']} values from: {level['values']}"""))


def get_datasets(levels: list[DatasetLevel]) -> list[ExactDataset]:
    """
    Return all datasets requested by config, in the given levels order.
    """
    return product(*(level["values"] for level in levels))


def write_command_configs(
    config: dict[str, Any],
    rule_name: str,
    datasets: list[ExactDataset],
    output_dir: str,
) -> None:
    """
    Write a per-dataset Augur command config, one file per dataset.
    """
    for dataset in datasets:
        out = get_rule_config(config, rule_name, dataset)
        path = dataset_config_path(output_dir, dataset, rule_name)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            print(f"# {'/'.join(dataset)}", file=f)
            yaml.dump(out, f, sort_keys=False, Dumper=NoAliasDumper)
        print(f"Saved {rule_name} config to {path!r}.", file=sys.stderr)


def dataset_config_path(output_dir: str, dataset: ExactDataset, rule_name: str) -> str:
    """
    Path of the augur config written for a dataset and rule.

    The path is '<output_dir>/<dataset>/<rule_name>_config.yaml', where
    '<dataset>' is the dataset's slash-joined values.
    """
    return f"{output_dir}/{'/'.join(dataset)}/{rule_name}_config.yaml"


def matching_pattern_values(
    patterned_config: dict[str, Any],
    dataset: ExactDataset,
) -> list[Any]:
    """
    Return the values from a {pattern: value} mapping whose pattern matches the
    dataset, preserving insertion order.
    """
    return [
        value
        for pattern, value in patterned_config.items()
        if pattern_matches_dataset(pattern, dataset)
    ]


def get_rule_config(
    config: dict[str, Any],
    rule_name: str,
    dataset: ExactDataset,
) -> dict[str, Any]:
    """
    Build the config for a rule and dataset.

    A matching 'custom_<rule>' replaces '<rule>' entirely: if any matching layer
    defines it, the '<rule>' layers are discarded and the config is built from
    the 'custom_<rule>' layers alone (e.g. 'custom_subsample' replaces the
    default 'subsample'). Otherwise the config is built from the '<rule>' layers.

    Within either, layers are merged top-to-bottom with later values overriding
    earlier ones.
    """
    if custom_layers := get_rule_layers(config, rule_override_name(rule_name), dataset):
        return merge_layers(custom_layers)

    return merge_layers(get_rule_layers(config, rule_name, dataset))


def rule_override_name(rule_name: str) -> str:
    return f"custom_{rule_name}"


def get_rule_layers(
    config: dict[str, Any],
    rule_name: str,
    dataset: ExactDataset,
) -> list[dict[str, Any]]:
    """
    Config layers for a rule and dataset, lowest priority first.

    The top-level '<rule>' key maps dataset patterns to config layers.
    Matching '<rule>.<pattern>' configs apply in pattern order.
    """
    layers = []
    if rule_name in config:
        layers += matching_pattern_values(config[rule_name], dataset)
    return layers


def merge_layers(layers: list[dict[str, Any]]) -> dict[str, Any]:
    """
    Deep-merge config layers in order, with later layers winning.
    """
    merged: dict[str, Any] = {}
    for layer in layers:
        deep_merge(merged, layer)
    return merged


def deep_merge(base: dict[str, Any], override: dict[str, Any]) -> None:
    """
    Recursively merge 'override' into 'base', mutating 'base'.

    Mappings are merged recursively; scalars and lists overwrite. Dicts brought
    in from 'override' are deep-copied so the source config is never mutated.
    Null-deletion is supported: keys mapping to a value of None (represented in
    YAML as null, ~, or an empty value) in 'override' are deleted from 'base'.
    """
    for key, value in override.items():
        if value is None:
            base.pop(key, None)
        elif isinstance(value, dict) and isinstance(base.get(key), dict):
            deep_merge(base[key], value)
        elif isinstance(value, dict):
            base[key] = copy.deepcopy(value)
        else:
            base[key] = value


def pattern_matches_dataset(
    pattern: str,
    dataset: ExactDataset,
) -> bool:
    """
    Return whether a dataset pattern matches an exact dataset.
    """
    pattern_parts = parse_dataset_pattern(pattern)
    if len(pattern_parts) != len(dataset):
        return False

    for pattern_part, dataset_value in zip(pattern_parts, dataset):
        if pattern_part["type"] == "wildcard":
            continue

        if dataset_value not in pattern_part["matches"]:
            return False

    return True


def parse_dataset_pattern(pattern: str) -> tuple[DatasetPatternPart, ...]:
    """
    Parse a slash-delimited dataset pattern.
    """
    return tuple(parse_dataset_pattern_part(part) for part in pattern.split("/"))


def parse_dataset_pattern_part(part: str) -> DatasetPatternPart:
    """
    Parse one part of a dataset pattern.

    Supported syntax:
    1. A literal value : 6y
    2. Multiple values : (6y|3y)
    3. All values      : *
    """
    if part == "*":
        return {"type": "wildcard", "matches": None}

    if part.startswith("(") and part.endswith(")"):
        values = tuple(part[1:-1].split("|"))
        if not values or any(not value for value in values):
            raise InvalidConfigError(f"Invalid multivalue dataset part {part!r}.")
        return {"type": "multivalue", "matches": values}

    if any(char in part for char in "()|"):
        raise InvalidConfigError(dedent(f"""\
            Invalid subsample dataset part {part!r}.
            Use '*', a literal value, or a whole-part multivalue like '(genome|N450)'."""))

    return {"type": "literal", "matches": (part,)}


def indented_list(xs, prefix):
    return f"\n{prefix}".join(xs)


try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
