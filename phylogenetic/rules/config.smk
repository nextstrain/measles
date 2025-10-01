"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/config_raw.yaml
    results/config_processed.yaml
"""
from copy import deepcopy

# Dump the unmodified config to a YAML file.
# This is useful for debugging the outcome of Snakemake's config merge (which
# would've already happened by this point) and custom config processing (which
# is about to happen).
write_config(config, "results/config_raw.yaml")

# Copy the config into a new variable, to be modified. We could modify 'config'
# in-place, but the new name highlights its modified state.
processed_config = deepcopy(config)

# This is similar to wildcards functionality in Snakemake.
# FIXME: builds, from config
for gene in ['genome', 'N450']:
    processed_config["files"][gene] = dict()
    processed_config["files"][gene]["reference"] = processed_config["files"]["reference"].format(gene=gene)
    processed_config["files"][gene]["auspice_config"] = processed_config["files"]["auspice_config"].format(gene=gene)

# Note: this is not in the loop because there is no file for gene=genome.
processed_config["files"]["N450"]["reference_fasta"] = processed_config["files"]["reference_fasta"].format(gene=gene)

# Remove config keys that have been replaced above.
del processed_config["files"]["reference"]
del processed_config["files"]["reference_fasta"]
del processed_config["files"]["auspice_config"]

# NOTE: The order is important. Filepaths must be resolved before config is
# written, otherwise augur subsample will not work.

# Resolve filepaths in the modified config variable.
resolve_filepaths(processed_config, [
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

# Write the modified config to a file. This will be used by augur subsample.
write_config(processed_config, "results/config_processed.yaml")
