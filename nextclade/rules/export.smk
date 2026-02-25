"""
This part of the workflow collects the phylogenetic tree and annotations to
export a Nextstrain dataset.

See Augur's usage docs for these commands for more details.
"""

rule export:
    """Exporting data files for auspice"""
    input:
        tree = "results/tree.nwk",
        metadata = "data/metadata.tsv",
        branch_lengths = "results/branch_lengths_div_only.json",
        clades = "results/clades.json",
        nt_muts = "results/nt_muts.json",
        aa_muts = "results/aa_muts.json",
        colors = resolve_config_path(config["files"]["colors"]),
        auspice_config = resolve_config_path(config["files"]["auspice_config"])
    output:
        auspice_json = "auspice/measles.json"
    params:
        strain_id = config["strain_id_field"],
        metadata_columns = config["export"]["metadata_columns"]
    shell:
        r"""
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --node-data {input.branch_lengths} {input.nt_muts} {input.aa_muts} {input.clades} \
            --colors {input.colors} \
            --metadata-columns {params.metadata_columns} \
            --auspice-config {input.auspice_config} \
            --include-root-sequence-inline \
            --output {output.auspice_json}
        """
