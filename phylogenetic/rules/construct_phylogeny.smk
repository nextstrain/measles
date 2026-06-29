"""
This part of the workflow constructs the phylogenetic tree.

See Augur's usage docs for these commands for more details.
"""

rule tree:
    """Building tree"""
    input:
        alignment = "results/{gene_or_genome}/{region}/aligned.fasta"
    output:
        tree = "results/{gene_or_genome}/{region}/tree_raw.nwk"
    log:
        "logs/tree_{gene_or_genome}_{region}.txt",
    benchmark:
        "benchmarks/tree_{gene_or_genome}_{region}.txt",
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
        tree = "results/{gene_or_genome}/{region}/tree_raw.nwk",
        alignment = "results/{gene_or_genome}/{region}/aligned.fasta",
        metadata = "results/metadata.tsv"
    output:
        tree = "results/{gene_or_genome}/{region}/tree.nwk",
        node_data = "results/{gene_or_genome}/{region}/branch_lengths.json"
    params:
        args = lambda w: config['refine'][f"{w.gene_or_genome}/{w.region}"],
        strain_id = config["strain_id_field"],
    log:
        "logs/refine_{gene_or_genome}_{region}.txt",
    benchmark:
        "benchmarks/refine_{gene_or_genome}_{region}.txt",
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
