"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

See Augur's usage docs for these commands for more details.
"""
from augur.subsample import get_referenced_files


rule align:
    input:
        sequences = "results/sequences.fasta",
        reference = resolve_config_path(config["files"]["reference_fasta"]),
    output:
        sequences = "results/align_{gene_or_genome}.fasta",
    params:
        nextclade_args = lambda w: config["nextclade"][w.gene_or_genome],
    log:
        "logs/align_{gene_or_genome}.txt",
    benchmark:
        "benchmarks/align_{gene_or_genome}.txt",
    threads: workflow.cores
    shell:
        r"""
        exec &> >(tee {log:q})

        nextclade run \
            -j {threads} \
            --input-ref {input.reference} \
            --output-fasta {output.sequences} \
            {params.nextclade_args} \
            {input.sequences}
        """

rule subsample:
    input:
        config = "results/{gene_or_genome}/{region}/subsample_config.yaml",
        sequences = "results/align_{gene_or_genome}.fasta",
        metadata = "results/metadata.tsv",
        referenced_files = lambda w: get_referenced_files(f"results/{w.gene_or_genome}/{w.region}/subsample_config.yaml"),
    output:
        sequences = "results/{gene_or_genome}/{region}/aligned.fasta"
    params:
        strain_id = config["strain_id_field"]
    log:
        "logs/subsample_{gene_or_genome}_{region}.txt",
    benchmark:
        "benchmarks/subsample_{gene_or_genome}_{region}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur subsample \
            --config {input.config} \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output-sequences {output.sequences}
        """
