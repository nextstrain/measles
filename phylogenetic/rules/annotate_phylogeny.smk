"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

See Augur's usage docs for these commands for more details.

"""

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/{gene_or_genome}/{region}/tree.nwk",
        alignment = "results/{gene_or_genome}/{region}/aligned.fasta"
    output:
        node_data = "results/{gene_or_genome}/{region}/nt_muts.json"
    params:
        inference = config["ancestral"]["inference"]
    log:
        "logs/ancestral_{gene_or_genome}_{region}.txt",
    benchmark:
        "benchmarks/ancestral_{gene_or_genome}_{region}.txt",
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
        tree = "results/{gene_or_genome}/{region}/tree.nwk",
        node_data = "results/{gene_or_genome}/{region}/nt_muts.json",
        reference = resolve_config_path(config["files"]["reference"])
    output:
        node_data = "results/{gene_or_genome}/{region}/aa_muts.json"
    log:
        "logs/translate_{gene_or_genome}_{region}.txt",
    benchmark:
        "benchmarks/translate_{gene_or_genome}_{region}.txt",
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
        tree = "results/{gene_or_genome}/{region}/tree.nwk",
        metadata = "results/metadata.tsv"
    output:
        node_data = "results/{gene_or_genome}/{region}/traits.json"
    params:
        columns = lambda w: config["traits"][f"{w.gene_or_genome}/{w.region}"]["columns"],
        sampling_bias_correction = lambda w: config["traits"][f"{w.gene_or_genome}/{w.region}"]["sampling_bias_correction"],
        strain_id = config["strain_id_field"]
    log:
        "logs/traits_{gene_or_genome}_{region}.txt",
    benchmark:
        "benchmarks/traits_{gene_or_genome}_{region}.txt",
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
