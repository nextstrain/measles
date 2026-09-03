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
    dump_and_validate(
        "results/run_config.yaml",
        Path(workflow.basedir) / "config.schema.yaml"
    )
    normalize_config()
    validate_config_values()
    write_rule_configs()


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


def write_rule_configs():
    # Support "custom_subsample" section to avoid defaults inheritance from "subsample"
    for build in config["builds"]:
        if "custom_subsample" in config:
            section = ["custom_subsample", build]
        else:
            section = ["subsample", build]
        write_config(f"results/{build}/subsample_config.yaml", section=section)

    for rule in ["refine", "traits"]:
        for build in config["builds"]:
            if config[rule][build]:
                section = [rule, build]
                write_config(f"results/{build}/{rule}_config.yaml", section=section)


try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
