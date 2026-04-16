"""
This part of the workflow constructs the phylogenetic tree.

See Augur's usage docs for these commands for more details.
"""

rule tree:
    """Building tree"""
    input:
        alignment = "results/{build}/aligned.fasta"
    output:
        tree = "results/{build}/tree_raw.nwk"
    log:
        "logs/tree_{build}.txt",
    benchmark:
        "benchmarks/tree_{build}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur tree \
            --alignment {input.alignment} \
            --output {output.tree}
        """

rule refine:
    """
    Refining tree
      - estimate timetree
    """
    input:
        tree = "results/{build}/tree_raw.nwk",
        alignment = "results/{build}/aligned.fasta",
        metadata = "results/metadata.tsv",
        config = "results/{build}/refine_config.yaml",
    output:
        tree = "results/{build}/tree.nwk",
        node_data = "results/{build}/branch_lengths.json"
    params:
        strain_id = config["strain_id_field"]
    log:
        "logs/refine_{build}.txt",
    benchmark:
        "benchmarks/refine_{build}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur refine \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output-tree {output.tree} \
            --output-node-data {output.node_data} \
            --config {input.config} \
            --timetree \
            --date-confidence \
            --stochastic-resolve
        """
