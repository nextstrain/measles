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

RUN_CONFIG = f"results/run_config.yaml"

def main():
    validate_config()
    write_config(RUN_CONFIG)


def write_config(path):
    """
    Write Snakemake's 'config' variable to a file.

    This is used for the subsample rule and is generally useful for debugging.
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)

    with open(path, 'w') as f:
        yaml.dump(config, f, sort_keys=False)

    print(f"Saved current run config to {path!r}.", file=sys.stderr)


def validate_config():
    """
    Validate the Snakemake config against the JSON schema.

    Raises SystemExit if validation fails or schema is missing.
    """

    schema_file = os.path.join(workflow.basedir, "config_schema.yaml")

    try:
        with open(schema_file, 'r') as f:
            schema = yaml.safe_load(f)

        jsonschema.validate(config, schema)
        print("✓ Configuration validation passed.", file=sys.stderr)

    except yaml.YAMLError as e:
        print(f"Error: Invalid YAML in schema file {schema_file}: {e}", file=sys.stderr)
        sys.exit(1)
    except jsonschema.ValidationError as e:
        error_message = dedent(f"""
        Configuration validation failed:

        Error at path: {' -> '.join(str(p) for p in e.absolute_path) if e.absolute_path else 'root'}
        Message: {e.message}

        Failed value: {e.instance}
        """).strip()
        print(error_message, file=sys.stderr)
        sys.exit(1)
    except jsonschema.SchemaError as e:
        print(f"Error: Invalid schema file {schema_file}: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error during validation: {e}", file=sys.stderr)
        sys.exit(1)


main()