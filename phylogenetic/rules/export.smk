"""
This part of the workflow collects the phylobuildtic tree and annotations to
export a Nextstrain dataset.

See Augur's usage docs for these commands for more details.
"""

rule colors:
    """Generate colors from ordering"""
    input:
        ordering = resolve_config_path("defaults/color_ordering.tsv"),
        color_schemes = resolve_config_path("defaults/color_schemes.tsv"),
        metadata = "data/metadata.tsv"
    output:
        colors = "results/colors.tsv"
    shell:
        """
        python3 {workflow.basedir}/scripts/assign-colors.py \
            --ordering {input.ordering} \
            --color-schemes {input.color_schemes} \
            --metadata {input.metadata} \
            --output {output.colors}
        """

rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/{build}/tree.nwk",
        metadata = "data/metadata.tsv",
        branch_lengths = "results/{build}/branch_lengths.json",
        nt_muts = "results/{build}/nt_muts.json",
        aa_muts = "results/{build}/aa_muts.json",
        traits = lambda w: f"results/{w.build}/traits.json" if w.build == "genome" else [],
        colors = "results/colors.tsv",
        auspice_config = resolve_config_path(config["files"]["auspice_config"]),
        description=resolve_config_path(config["files"]["description"])
    output:
        auspice_json = "auspice/measles_{build}.json"
    params:
        strain_id = config["strain_id_field"],
        metadata_columns = config["export"]["metadata_columns"],
        traits = lambda w: f"results/{w.build}/traits.json" if w.build == "genome" else ""
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --node-data {input.branch_lengths} {input.nt_muts} {input.aa_muts} {params.traits} \
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
        strain_id = config["strain_id_field"],
        min_date = config["tip_frequencies"]["min_date"],
        max_date = config["tip_frequencies"]["max_date"],
        narrow_bandwidth = config["tip_frequencies"]["narrow_bandwidth"],
        wide_bandwidth = config["tip_frequencies"]["wide_bandwidth"]
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
