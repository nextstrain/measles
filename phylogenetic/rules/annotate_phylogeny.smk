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
        inference = config["ancestral"]["inference"]
    log:
        "logs/ancestral_{build}.txt",
    benchmark:
        "benchmarks/ancestral_{build}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

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
        reference = resolve_config_path(config["files"]["reference"])
    output:
        node_data = "results/{build}/aa_muts.json"
    log:
        "logs/translate_{build}.txt",
    benchmark:
        "benchmarks/translate_{build}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output {output.node_data}
        """

rule traits:
    """Inferring ancestral traits for {params.columns!s}"""
    input:
        tree = "results/{build}/tree.nwk",
        metadata = "results/metadata.tsv"
    output:
        node_data = "results/{build}/traits.json"
    wildcard_constraints:
        build = "genome"
    params:
        columns = config["traits"]["columns"],
        sampling_bias_correction = config["traits"]["sampling_bias_correction"],
        strain_id = config["strain_id_field"]
    log:
        "logs/traits_{build}.txt",
    benchmark:
        "benchmarks/traits_{build}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur traits \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output {output.node_data} \
            --columns {params.columns} \
            --confidence \
            --sampling-bias-correction {params.sampling_bias_correction}
        """
