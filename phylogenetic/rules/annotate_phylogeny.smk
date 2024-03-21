"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

See Augur's usage docs for these commands for more details.

"""

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/tree_{gene}.nwk",
        alignment = "results/aligned_{gene}.fasta"
    output:
        node_data = "results/nt_muts_{gene}.json"
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
        tree = "results/tree_{gene}.nwk",
        node_data = "results/nt_muts_{gene}.json",
        reference = lambda wildcard: "defaults/measles_reference.gb" if wildcard.gene in ["genome"] else "defaults/measles_reference_{gene}.gb"
    output:
        node_data = "results/aa_muts_{gene}.json"
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output {output.node_data} \
        """
