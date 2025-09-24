"""
This part of the workflow prepares sequences for constructing the phylogenetic tree for 450bp of the N gene.

See Augur's usage docs for these commands for more details.
"""

rule align_and_extract_N450:
    input:
        sequences = "data/sequences.fasta",
        reference = resolve_config_path(config["files"]["reference_fasta"])({"gene":"N450"})
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

rule filter_N450:
    """
    Filtering to
      - {params.sequences_per_group} sequence(s) per {params.group_by!s}
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
      - excluding strains with missing region, country or date metadata
    """
    input:
        config = "results/run_config.yaml",
        sequences = "results/N450/sequences.fasta",
        metadata = "data/metadata.tsv"
    output:
        sequences = "results/N450/aligned.fasta"
    params:
        config_section = ["custom_subsample" if config.get("custom_subsample") else "subsample", "N450"],
        strain_id = config["strain_id_field"]
    shell:
        """
        augur subsample \
            --config {input.config} \
            --config-section {params.config_section:q} \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output-sequences {output.sequences} \
        """
