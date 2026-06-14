"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
from textwrap import dedent


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
    pass


def write_subsample_config():
    for build in config["builds"]:
        if "custom_subsample" in config:
            section = ["custom_subsample", build]
        else:
            section = ["subsample", build]
        write_config(f"results/{build}/subsample_config.yaml", section=section)


def indented_list(xs, prefix):
    return f"\n{prefix}".join(xs)


try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
