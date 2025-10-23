"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
config = load_config()

write_config("results/run_config.yaml")
