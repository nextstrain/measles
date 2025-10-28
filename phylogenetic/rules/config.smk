"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
config = load_config()

write_config("results/run_config.yaml")

# Write subsample configuration files.
# Do this outside of a rule to take advantage of Snakemake's file change detection.
for build in config["builds"]:
    section = ["subsample", build]
    write_config(f"results/{build}/subsample_config.yaml", section=section)
