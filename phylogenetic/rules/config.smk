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
    # Config keys whose value must be a dict keyed by build name, with one entry
    # for each build listed in config.builds. (Extra values are allowed so that
    # you can specify a custom subset of builds via --config or similar.)
    per_build_keys = ["subsample", "refine", "traits", "export"]

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

    # gene_or_genome wildcard values must be present in the nextclade config entry
    if not isinstance(config['nextclade'], dict):
        raise InvalidConfigError(
            f"Config 'config.nextclade' must be a dict but it is a {type(value).__name__}"
        )
    missing_gene_or_genome_vals = set([build.split("/")[0] for build in config["builds"]]) - set(config['nextclade'].keys())
    if len(missing_gene_or_genome_vals):
        raise InvalidConfigError(
            f"The keys of 'config.nextclade' must contain all necessary 'gene_of_geneome' values; "
            f"you are currently missing ({', '.join(sorted(missing_gene_or_genome_vals))})"
        )



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
