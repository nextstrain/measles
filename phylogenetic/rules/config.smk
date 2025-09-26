"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
resolve_filepaths([
    ("subsample", "*", "samples", "*", "include"),
    ("subsample", "*", "samples", "*", "exclude"),
    ("subsample", "*", "samples", "*", "group_by_weights"),
    ("custom_subsample", "*", "samples", "*", "include"),
    ("custom_subsample", "*", "samples", "*", "exclude"),
    ("custom_subsample", "*", "samples", "*", "group_by_weights"),
])

write_config("results/run_config.yaml")
