"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""

# NOTE: The order is important. Filepaths must be resolved before config is
# written, otherwise augur subsample will not work.

config = load_config()

resolve_filepaths([
    ("subsample", "*", "samples", "*", "include"),
    ("subsample", "*", "samples", "*", "exclude"),
    ("subsample", "*", "samples", "*", "group_by_weights"),
])

write_config("results/run_config.yaml")
