"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/config_raw.yaml
    results/config_processed.yaml
"""


def main():
    # NOTE: The order is important. Filepaths must be resolved before config is
    # written, otherwise augur subsample will not work.

    # 1. Dump the unmodified config to a YAML file.
    #    This is useful for debugging the outcome of Snakemake's config merge
    #    (which would've already happened by this point) and custom config
    #    processing (which is about to happen).
    write_config("results/config_raw.yaml")

    # 2. Process the config.
    #    The config structure is workflow-specific, so this is a
    #    workflow-specific step.
    process_config()

    # 3. Write the modified config to a file.
    #    This will be used by augur subsample.
    write_config("results/config_processed.yaml")


def process_config():
    """
    Modify Snakemake's config variable in-place.
    """
    # 1. Modify config structure.
    expand_wildcards()

    # 2. Resolve filepaths.
    resolve_filepaths([
        ("files", "colors"),
        ("files", "description"),
        ("files", "*", "reference"),
        ("files", "*", "reference_fasta"),
        ("files", "*", "auspice_config"),
        ("subsample", "*", "samples", "*", "include"),
        ("subsample", "*", "samples", "*", "exclude"),
        ("subsample", "*", "samples", "*", "group_by_weights"),
        ("custom_subsample", "*", "samples", "*", "include"),
        ("custom_subsample", "*", "samples", "*", "exclude"),
        ("custom_subsample", "*", "samples", "*", "group_by_weights"),
    ])


def expand_wildcards():
    global config

    # Example:
    #   files.reference = "reference_{build}.gb"
    # becomes
    #   files.genome.reference = "reference_genome.gb"
    #   files.N450.reference = "reference_N450.gb"
    for build in config['builds']:
        config["files"][build] = dict()
        config["files"][build]["reference"] = config["files"]["reference"].format(build=build)
        config["files"][build]["auspice_config"] = config["files"]["auspice_config"].format(build=build)

    # Note: this is not in the loop because there is no file for build=genome.
    config["files"]["N450"]["reference_fasta"] = config["files"]["reference_fasta"].format(build=build)

    # Remove unexpanded config entries.
    del config["files"]["reference"]
    del config["files"]["reference_fasta"]
    del config["files"]["auspice_config"]

main()
