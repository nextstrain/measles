"""
This part of the workflow constructs the phylogenetic tree.

See Augur's usage docs for these commands for more details.
"""

rule tree:
    """Building tree"""
    input:
        alignment = "results/{gene}/{region}/aligned.fasta"
    output:
        tree = "results/{gene}/{region}/tree_raw.nwk"
    log:
        "logs/tree_{gene}_{region}.txt",
    benchmark:
        "benchmarks/tree_{gene}_{region}.txt",
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
      - use {params.coalescent} coalescent timescale
      - estimate {params.date_inference} node dates
      - filter tips more than {params.clock_filter_iqd} IQDs from clock expectation
    """
    input:
        tree = "results/{gene}/{region}/tree_raw.nwk",
        alignment = "results/{gene}/{region}/aligned.fasta",
        metadata = "results/metadata.tsv",
        config = lambda w: dataset_config_path("results", (w.gene, w.region), "refine"),
    output:
        tree = "results/{gene}/{region}/tree.nwk",
        node_data = "results/{gene}/{region}/branch_lengths.json"
    params:
        strain_id = config["strain_id_field"],
    log:
        "logs/refine_{gene}_{region}.txt",
    benchmark:
        "benchmarks/refine_{gene}_{region}.txt",
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
            --config {input.config}
        """
