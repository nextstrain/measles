"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

See Augur's usage docs for these commands for more details.
"""
from augur.subsample import get_referenced_files

rule subsample:
    input:
        config = "results/genome/subsample_config.yaml",
        sequences = "results/sequences.fasta",
        metadata = "results/metadata.tsv",
        referenced_files = get_referenced_files("results/genome/subsample_config.yaml"),
    output:
        sequences = "results/genome/subsampled.fasta"
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

rule align:
    """
    Aligning sequences to {input.reference}
      - filling gaps with N
    """
    input:
        sequences = "results/genome/subsampled.fasta",
        reference = resolve_config_path(config["files"]["reference"])({"build": "genome"})
    output:
        alignment = "results/genome/aligned.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference
        """
