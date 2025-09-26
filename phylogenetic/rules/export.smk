"""
This part of the workflow collects the phylogenetic tree and annotations to
export a Nextstrain dataset.

See Augur's usage docs for these commands for more details.
"""

rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/{gene}/tree.nwk",
        metadata = "data/metadata.tsv",
        branch_lengths = "results/{gene}/branch_lengths.json",
        nt_muts = "results/{gene}/nt_muts.json",
        aa_muts = "results/{gene}/aa_muts.json",
        colors = config["files"]["colors"],
        auspice_config = lambda w: config["files"][w.gene]["auspice_config"],
        description = config["files"]["description"]
    output:
        auspice_json = "auspice/measles_{gene}.json"
    params:
        strain_id = config["strain_id_field"],
        metadata_columns = config["export"]["metadata_columns"]
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --node-data {input.branch_lengths} {input.nt_muts} {input.aa_muts} \
            --colors {input.colors} \
            --metadata-columns {params.metadata_columns} \
            --auspice-config {input.auspice_config} \
            --include-root-sequence-inline \
            --output {output.auspice_json} \
            --description {input.description}
        """

rule tip_frequencies:
    """
    Estimating KDE frequencies for tips
    """
    input:
        tree = "results/{gene}/tree.nwk",
        metadata = "data/metadata.tsv"
    params:
        strain_id = config["strain_id_field"],
        min_date = config["tip_frequencies"]["min_date"],
        max_date = config["tip_frequencies"]["max_date"],
        narrow_bandwidth = config["tip_frequencies"]["narrow_bandwidth"],
        wide_bandwidth = config["tip_frequencies"]["wide_bandwidth"]
    output:
        tip_freq = "auspice/measles_{gene}_tip-frequencies.json"
    shell:
        """
        augur frequencies \
            --method kde \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --min-date {params.min_date} \
            --max-date {params.max_date} \
            --narrow-bandwidth {params.narrow_bandwidth} \
            --wide-bandwidth {params.wide_bandwidth} \
            --output {output.tip_freq}
        """
