"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
    results/{gene}/{region}/subsample_config.yaml
"""
from augur.subsample import merge_defaults

def main():
    normalize_config()
    levels = config["dataset_levels"]
    rule_names = ["subsample", "refine", "traits", "export"]

    validate_rule_configs(config, rule_names, levels)
    validate_nextclade_config()

    for build in config["builds"]:
        # Resolve and write subsample config file
        subsample_config = resolve_rule_config(config, "subsample", build, levels)
        subsample_config = merge_defaults(subsample_config)
        write_rule_config(f"results/{build}/subsample_config.yaml", subsample_config, build)

        # Resolve other rule configs in-place (no separate file needed)
        for rule_name in ["refine", "traits", "export"]:
            config[rule_name][build] = resolve_rule_config(config, rule_name, build, levels)

    write_config("results/run_config.yaml")


def normalize_config():
    # Normalize scalar string to a single-item list
    if isinstance(config['builds'], str):
        config['builds'] = [config['builds']]


def validate_nextclade_config():
    if not isinstance(config['nextclade'], dict):
        raise InvalidConfigError(
            f"Config 'config.nextclade' must be a dict but it is a {type(config['nextclade']).__name__}"
        )
    missing_gene_vals = set(config["dataset_levels"]["gene"]) - set(config['nextclade'].keys())
    if len(missing_gene_vals):
        raise InvalidConfigError(
            f"The keys of 'config.nextclade' must contain all necessary 'gene' values; "
            f"you are currently missing ({', '.join(sorted(missing_gene_vals))})"
        )


try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
