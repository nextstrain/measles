"""
This part of the workflow prepares sequences for constructing the phylogenetic tree for 450bp of the N gene.

See Augur's usage docs for these commands for more details.
"""

rule align_and_extract_N450:
    input:
        sequences = "data/sequences.fasta",
        reference = config["files"]["reference_N450_fasta"]
    output:
        sequences = "results/N450/sequences.fasta"
    params:
        min_length = config['filter_N450']['min_length']
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
        sequences = "results/N450/sequences.fasta",
        metadata = "data/metadata.tsv",
        exclude = config["files"]["exclude"],
        include = config["files"]["include_N450"]
    output:
        sequences = "results/N450/aligned.fasta"
    params:
        group_by = config['filter_N450']['group_by'],
        subsample_max_sequences = config["filter_N450"]["subsample_max_sequences"],
        min_date = config["filter_N450"]["min_date"],
        min_length = config['filter_N450']['min_length'],
        strain_id = config["strain_id_field"]
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --exclude {input.exclude} \
            --output {output.sequences} \
            --group-by {params.group_by} \
            --subsample-max-sequences {params.subsample_max_sequences} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        """