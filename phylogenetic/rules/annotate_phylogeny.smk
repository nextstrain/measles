"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

See Augur's usage docs for these commands for more details.

"""

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        config = "results/{build}/ancestral_config.yaml",
        tree = "results/{build}/tree.nwk",
        alignment = "results/{build}/aligned.fasta",
        # FIXME: referenced_files = lambda w: get_referenced_files(f"results/{w.build}/ancestral_config.yaml"),
    output:
        node_data = "results/{build}/nt_muts.json"
    log:
        "logs/{build}/ancestral.txt",
    benchmark:
        "benchmarks/{build}/ancestral.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur ancestral \
            --config {input.config} \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output-node-data {output.node_data}
        """

rule translate:
    """Translating amino acid sequences"""
    input:
        config = "results/{build}/translate_config.yaml",
        tree = "results/{build}/tree.nwk",
        node_data = "results/{build}/nt_muts.json",
        # FIXME: referenced_files = lambda w: get_referenced_files(f"results/{w.build}/translate_config.yaml"),
    output:
        node_data = "results/{build}/aa_muts.json"
    log:
        "logs/{build}/translate.txt",
    benchmark:
        "benchmarks/{build}/translate.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur translate \
            --config {input.config} \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --output {output.node_data}
        """

rule traits:
    """Inferring ancestral traits"""
    input:
        config = "results/{build}/traits_config.yaml",
        tree = "results/{build}/tree.nwk",
        metadata = "results/metadata.tsv"
    output:
        node_data = "results/{build}/traits.json"
    params:
        strain_id = config["strain_id_field"]
    log:
        "logs/{build}/traits.txt",
    benchmark:
        "benchmarks/{build}/traits.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur traits \
            --config {input.config} \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output {output.node_data}
        """
