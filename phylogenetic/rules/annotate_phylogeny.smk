"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

See Augur's usage docs for these commands for more details.

"""

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/{build}/tree.nwk",
        alignment = "results/{build}/aligned.fasta"
    output:
        node_data = "results/{build}/nt_muts.json"
    params:
        inference = get_config_value("ancestral", "inference")
    shell:
        """
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output-node-data {output.node_data} \
            --inference {params.inference}
        """

rule translate:
    """Translating amino acid sequences"""
    input:
        tree = "results/{build}/tree.nwk",
        node_data = "results/{build}/nt_muts.json",
        reference = get_config_value("translate", "reference")
    output:
        node_data = "results/{build}/aa_muts.json"
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output {output.node_data} \
        """
