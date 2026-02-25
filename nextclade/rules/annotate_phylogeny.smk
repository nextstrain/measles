"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

See Augur's usage docs for these commands for more details.

"""

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/tree.nwk",
        alignment = "results/aligned.fasta"
    output:
        node_data = "results/nt_muts.json"
    params:
        inference = config["ancestral"]["inference"],
        reference_fasta = resolve_config_path(config["files"]["reference_N450_fasta"])
    shell:
        r"""
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output-node-data {output.node_data} \
            --inference {params.inference}  \
            --root-sequence {params.reference_fasta}
        """

rule translate:
    """Translating amino acid sequences"""
    input:
        tree = "results/tree.nwk",
        node_data = "results/nt_muts.json",
        reference = resolve_config_path(config["files"]["reference_N450"])
    output:
        node_data = "results/aa_muts.json"
    shell:
        r"""
        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output {output.node_data} \
        """

rule clades:
    input:
        tree = "results/tree.nwk",
        nt_muts = "results/nt_muts.json",
        aa_muts = "results/aa_muts.json",
        clade_defs = resolve_config_path(config["files"]["clades"])
    output:
        clades = "results/clades.json"
    shell:
        r"""
        augur clades \
            --tree {input.tree} \
            --mutations {input.nt_muts} {input.aa_muts} \
            --clades {input.clade_defs} \
            --output {output.clades}
        """

rule timeout:
    input: "results/branch_lengths.json"
    output: "results/branch_lengths_div_only.json"
    run:
        import json
        with open(input[0], 'r') as fh:
            data = json.load(fh)
        new_nodes = {}
        for name, attrs in data['nodes'].items():
            new_nodes[name] = {'mutation_length': attrs.get('mutation_length')}
        data['nodes'] = new_nodes
        with open(output[0], 'w') as fh:
            json.dump(data, fh, indent=2)
