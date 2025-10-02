"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
import os
import sys
import yaml
import jsonschema
from textwrap import dedent


def main():
    validate_config(os.path.join(workflow.basedir, "config_schema.yaml"))

    # NOTE: The order is important. Filepaths must be resolved before config is
    # written, otherwise augur subsample will not work.

    # FIXME: infer these directly from schema
    # subsample schema will need to be updated to mark filepaths.
    resolve_filepaths([
        ("subsample", "*", "samples", "*", "include"),
        ("subsample", "*", "samples", "*", "exclude"),
        ("subsample", "*", "samples", "*", "group_by_weights"),
        ("custom_subsample", "*", "samples", "*", "include"),
        ("custom_subsample", "*", "samples", "*", "exclude"),
        ("custom_subsample", "*", "samples", "*", "group_by_weights"),
    ])

    write_config("results/run_config.yaml")


def validate_config(schema_file):
    # FIXME: use augur validate?
    with open(schema_file, 'r') as f:
        schema = yaml.safe_load(f)
    try:
        jsonschema.validate(config, schema)
        print("✓ Configuration is valid.", file=sys.stderr)
    except Exception as e:
        print(f"ERROR: Config validation failed: {e}", file=sys.stderr)
        sys.exit(1)


main()
