"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
write_config("results/run_config.yaml")

# Write subsample configuration files.
for build in config["builds"]:
    if "custom_subsample" in config:
        section = ["custom_subsample", build]
    else:
        section = ["subsample", build]
    write_config(f"results/{build}/subsample_config.yaml", section=section)
