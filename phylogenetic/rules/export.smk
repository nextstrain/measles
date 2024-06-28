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
        auspice_config = lambda wildcard: "defaults/auspice_config.json" if wildcard.gene in ["genome"] else "defaults/auspice_config_N450.json"
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
            --output {output.auspice_json}
        """

rule final_tip_frequencies:
    input:
        tip_freq = "results/{gene}/tip-frequencies.json",
    output:
        tip_freq = "auspice/measles_{gene}_tip-frequencies.json"
    shell:
        """
        cp -f {input.tip_freq} {output.tip_freq}
        """
