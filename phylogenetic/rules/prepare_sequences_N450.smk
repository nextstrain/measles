"""
This part of the workflow prepares sequences for constructing the phylogenetic tree for 450bp of the N gene.

See Augur's usage docs for these commands for more details.
"""
from augur.subsample import get_referenced_files

rule align_and_extract_N450:
    input:
        sequences = "results/sequences.fasta",
        reference = resolve_config_path(config["files"]["reference_fasta"])({"build":"N450"})
    output:
        sequences = "results/N450/sequences.fasta"
    params:
        min_length = config["align_and_extract_N450"]["min_length"]
    shell:
        """
        nextclade run \
           -j 1 \
           --input-ref {input.reference} \
           --output-fasta {output.sequences} \
           --min-seed-cover 0.01 \
           --min-length {params.min_length} \
           --silent \
           {input.sequences}
        """

rule subsample_N450:
    input:
        config = "results/N450/subsample_config.yaml",
        sequences = "results/N450/sequences.fasta",
        metadata = "results/metadata.tsv",
        referenced_files = get_referenced_files("results/N450/subsample_config.yaml"),
    output:
        sequences = "results/N450/aligned.fasta"
    params:
        strain_id = config["strain_id_field"]
    shell:
        """
        augur subsample \
            --config {input.config} \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output-sequences {output.sequences} \
        """
