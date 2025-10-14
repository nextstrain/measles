"""
This part of the workflow collects the phylobuildtic tree and annotations to
export a Nextstrain dataset.

See Augur's usage docs for these commands for more details.
"""

rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/{build}/tree.nwk",
        metadata = "data/metadata.tsv",
        branch_lengths = "results/{build}/branch_lengths.json",
        nt_muts = "results/{build}/nt_muts.json",
        aa_muts = "results/{build}/aa_muts.json",
        colors = get_config_value("export", "colors"),
        auspice_config = get_config_value("export", "auspice_config"),
        description = get_config_value("export", "description")
    output:
        auspice_json = "auspice/measles_{build}.json"
    params:
        strain_id = get_config_value("export", "strain_id_field"),
        metadata_columns = get_config_value("export", "metadata_columns")
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
        tree = "results/{build}/tree.nwk",
        metadata = "data/metadata.tsv"
    params:
        strain_id = get_config_value("tip_frequencies", "strain_id_field"),
        min_date = get_config_value("tip_frequencies", "min_date"),
        max_date = get_config_value("tip_frequencies", "max_date"),
        narrow_bandwidth = get_config_value("tip_frequencies", "narrow_bandwidth"),
        wide_bandwidth = get_config_value("tip_frequencies", "wide_bandwidth")
    output:
        tip_freq = "auspice/measles_{build}_tip-frequencies.json"
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
