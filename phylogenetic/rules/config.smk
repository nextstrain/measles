"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
    results/{build}/subsample_config.yaml
"""
import jsonschema
import os
import sys
import yaml
from augur.config import resolve_filepaths
from augur.validate import validate_json, ValidateError
from pathlib import Path


def get_gene(build: str) -> str:
    """Extract the gene from a multi-part build string (e.g. 'genome/global' -> 'genome')."""
    return build.split("/")[0]


def main():
    schema = load_yaml(Path(workflow.basedir) / "config.schema.yaml")
    dump_and_validate("results/run_config.yaml", schema)
    normalize_config(schema)
    validate_config_values()
    write_subsample_config()


# TODO: move this to nextstrain/shared
def load_yaml(path):
    """
    Load a YAML file from a filepath.
    """
    with open(path, "r") as f:
        return yaml.safe_load(f)


def normalize_config(schema):
    # Normalize scalar string to a single-item list
    if isinstance(config['builds'], str):
        config['builds'] = [config['builds']]

    # Resolve filepaths
    search_paths = [Path(p) for p in os.environ["AUGUR_SEARCH_PATHS"].split(":")]
    resolve_filepaths(config, search_paths, schema)


# TODO: move this to nextstrain/shared
def dump_and_validate(dump_path, schema):
    """
    Write Snakemake's 'config' variable to a file, then validate it against the
    schema. Do both in the same function so that the validation output can
    easily reference the path of the dumped config for inspection.
    """
    global config

    write_config(dump_path)

    Validator = jsonschema.validators.validator_for(schema)
    validator = Validator(schema)

    try:
        validate_json(config, validator, dump_path)
    except ValidateError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        exit(1)


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

    # Config keys whose value must be a dict keyed by gene name, with one entry
    # for each gene in requested builds.
    genes = set(get_gene(build) for build in config["builds"])
    for key in ["align", "translate", "nextclade"]:
        if missing_genes := genes - set(config[key]):
            raise InvalidConfigError(
                f"The keys of 'config.{key}' must contain all necessary genes; "
                f"you are currently missing ({', '.join(sorted(missing_genes))})"
            )


def write_subsample_config():
    for build in config["builds"]:
        if "custom_subsample" in config:
            section = ["custom_subsample", build]
        else:
            section = ["subsample", build]
        write_config(f"results/{build}/subsample_config.yaml", section=section)


try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
