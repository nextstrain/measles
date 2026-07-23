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
        "logs/{build}/tree.txt",
    benchmark:
        "benchmarks/{build}/tree.txt",
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
        tree = "results/{build}/tree_raw.nwk",
        alignment = "results/{build}/aligned.fasta",
        metadata = "results/metadata.tsv"
    output:
        tree = "results/{build}/tree.nwk",
        node_data = "results/{build}/branch_lengths.json"
    params:
        args = lambda w: config['refine'][w.build],
        strain_id = config["strain_id_field"],
    log:
        "logs/{build}/refine.txt",
    benchmark:
        "benchmarks/{build}/refine.txt",
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
            {params.args}
        """
