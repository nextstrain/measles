"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
    results/{build}/{rule}_config.yaml
"""
import sys
from pathlib import Path


def get_gene(build: str) -> str:
    """Extract the gene from a multi-part build string (e.g. 'genome/global' -> 'genome')."""
    return build.split("/")[0]


def main():
    schema_path = Path(workflow.basedir) / "config.schema.yaml"
    dump_and_validate(
        "results/run_config.yaml",
        schema_path
    )
    normalize_config()
    validate_config_values()
    write_rule_configs(schema_path)


def normalize_config():
    # Normalize scalar string to a single-item list
    if isinstance(config['builds'], str):
        config['builds'] = [config['builds']]


def validate_config_values():
    """
    Perform custom value checks that can't be handled by schema validation.
    """
    global config

    # Config keys whose value must be a dict keyed by build name, with one entry
    # for each build listed in config.builds. (Extra values are allowed so that
    # you can specify a custom subset of builds via --config or similar.)
    for key in ["subsample", "refine", "traits", "export"]:
        if missing_builds := set(config["builds"]) - set(config[key]):
            raise InvalidConfigError(
                f"The keys of 'config.{key}' must contain all requested builds; "
                f"you are currently missing ({', '.join(sorted(missing_builds))})"
            )

    # gene wildcard values must be present in the nextclade config entry
    if missing_gene_vals := set([get_gene(build) for build in config["builds"]]) - set(config['nextclade'].keys()):
        raise InvalidConfigError(
            f"The keys of 'config.nextclade' must contain all necessary 'gene' values; "
            f"you are currently missing ({', '.join(sorted(missing_gene_vals))})"
        )


def write_rule_configs(schema_path):
    schema = load_json_schema_locally(schema_path).schema

    # Support "custom_subsample" section to avoid defaults inheritance from "subsample"
    for build in config["builds"]:
        subsample_key = "custom_subsample" if "custom_subsample" in config else "subsample"
        config[subsample_key][build] = {
            "$schema": get_external_ref(schema["properties"][subsample_key]),
            **config[subsample_key][build],
        }
        write_config(f"results/{build}/subsample_config.yaml", section=[subsample_key, build])

    for rule in ["refine", "traits"]:
        for build in config["builds"]:
            if config[rule][build]:
                config[rule][build] = {
                    # Add $schema for augur.config.get_referenced_files().
                    # This isn't entirely accurate because the workflow config
                    # takes a subset of the Augur command's config schema
                    # (implemented via allOf), but the nuance doesn't matter for
                    # get_referenced_files().
                    "$schema": get_external_ref(schema["properties"][rule]),

                    **config[rule][build],
                }
                write_config(f"results/{build}/{rule}_config.yaml", section=[rule, build])


def get_external_ref(rule_schema):
    """Recursively search for a $ref URL in a rule's schema definition."""
    # Check mappings (patternProperties, build name patterns, etc.).
    if isinstance(rule_schema, dict):
        # Found!
        if "$ref" in rule_schema and rule_schema["$ref"].startswith("https://"):
            return rule_schema["$ref"]

        # Check within each mapping value.
        for val in rule_schema.values():
            if ref := get_external_ref(val):
                return ref

    # Check within allOf/oneOf entries.
    elif isinstance(rule_schema, list):
        for item in rule_schema:
            if ref := get_external_ref(item):
                return ref

    # No matching $ref found in this branch (dead end).
    return None


try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
