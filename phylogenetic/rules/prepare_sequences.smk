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
        sequences = "results/align_{gene}.fasta",
    params:
        nextclade_args = lambda w: config["nextclade"][w.gene],
    log:
        "logs/align_{gene}.txt",
    benchmark:
        "benchmarks/align_{gene}.txt",
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
        config = lambda w: dataset_config_path("results", (w.gene, w.region), "subsample"),
        sequences = "results/align_{gene}.fasta",
        metadata = "results/metadata.tsv",
        referenced_files = lambda w: get_referenced_files(dataset_config_path("results", (w.gene, w.region), "subsample")),
    output:
        sequences = "results/{gene}/{region}/aligned.fasta"
    params:
        strain_id = config["strain_id_field"]
    log:
        "logs/subsample_{gene}_{region}.txt",
    benchmark:
        "benchmarks/subsample_{gene}_{region}.txt",
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
