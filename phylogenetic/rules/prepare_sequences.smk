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

def get_gene(wildcards):
    """links the build wildcard to the gene wildcard"""
    ret = config['build_to_gene'].get(wildcards.build, False)
    if not ret:
        raise Error(f"Config.build_to_gene must define a mapping for the build wildcard {wildcards.build!r}")
    return ret

rule subsample:
    input:
        config = "results/{build}/subsample_config.yaml",
        sequences = lambda w: f"results/align_{get_gene(w)}.fasta",
        metadata = "results/metadata.tsv",
        referenced_files = lambda w: get_referenced_files(f"results/{w.build}/subsample_config.yaml"),
    output:
        sequences = "results/{build}/aligned.fasta"
    params:
        strain_id = config["strain_id_field"]
    log:
        "logs/subsample_{build}.txt",
    benchmark:
        "benchmarks/subsample_{build}.txt",
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
