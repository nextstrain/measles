"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

See Augur's usage docs for these commands for more details.

"""

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/{gene}/tree.nwk",
        alignment = "results/{gene}/aligned.fasta"
    output:
        node_data = "results/{gene}/nt_muts.json"
    params:
        inference = config["ancestral"]["inference"]
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
        tree = "results/{gene}/tree.nwk",
        node_data = "results/{gene}/nt_muts.json",
        reference = lambda wildcard: resolve_config_path(config["files"]["reference" if wildcard.gene == "genome" else f"reference_{wildcard.gene}"])
    output:
        node_data = "results/{gene}/aa_muts.json"
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output {output.node_data} \
        """
