"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
from textwrap import dedent


VALID_BUILDS = {"genome", "N450"}


def main():
    validate_config()

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

    write_subsample_config()
    write_config("results/run_config.yaml")


def validate_config():
    """
    Validate the config.

    This could be improved with a schema definition file, but for now it serves
    to provide useful error messages for common user errors and effects of
    breaking changes.
    """
    # Validate 'builds'
    if invalid_builds := set(config['builds']) - VALID_BUILDS:
        raise InvalidConfigError(dedent(f"""\
            The following names in 'builds' are not valid:

                {indented_list(invalid_builds, "                ")}

            Valid builds are:

                {indented_list(VALID_BUILDS, "                ")}
            """))


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
