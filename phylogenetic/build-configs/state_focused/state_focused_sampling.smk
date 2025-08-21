"""
This file provides custom rules to substitute the default sampling scheme.
These rules will supercede those included in the 'rules' directory
Rule 'copy_ingest_results' copies the results from the ingest pipeline.
Rule 'filter' applies to the whole-genome dataset.
Rule 'filter_N450' applies to the N450 dataset.
"""
rule copy_ingest_results:
    input:
        sequences="../ingest/results/sequences.fasta",
        metadata="../ingest/results/metadata.tsv",
    output:
        sequences="data/sequences.fasta",
        metadata="data/metadata.tsv",
    shell:
        """
            cp -f {input.sequences} {output.sequences}
            cp -f {input.metadata} {output.metadata}
        """

ruleorder: copy_ingest_results > decompress

rule filter_genomic_state:
    """
    Filtering {params.division} sequences to
      - {params.sequences_per_group_state} sequence(s) per {params.group_by_state!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
    
    Filtering {params.continental} sequences to
      - {params.sequences_per_group_continental} sequence(s) per {params.group_by_continental!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}

    """
    input:
        sequences="data/sequences.fasta",
        metadata="data/metadata.tsv",
        exclude=resolve_config_path(config["files"]["exclude"]),
        include=resolve_config_path(config["files"]["include"])({"gene": "genome"}),
    output:
        sequences="results/genome/filtered.fasta"
    params:
        strain_id=config["strain_id_field"],
        division=config["tiers"]["division"],
        continental=config["tiers"]["continental"],
        group_by_state=config["filter"]["group_by_state"],
        group_by_continental=config["filter"]["group_by_continental"],
        group_by_global=config["filter"]["group_by_global"],
        sequences_per_group_state=config["filter"]["sequences_per_group_state"],
        sequences_per_group_continental=config["filter"]["sequences_per_group_continental"],
        sequences_per_group_global=config["filter"]["sequences_per_group_global"],
        min_date=config["filter"]["min_date"],
        min_length=config["filter"]["min_length"]
    # The following shell block performs three sequential filtering steps (division, continental, global)
    # and then combines the filtered results with vaccine strains for the final output.
    shell:
        """
        # Filter sequences based on division
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division == '{params.division}'" \
            --exclude {input.exclude} \
            --output-strains results/genome/{params.division}_filtered.txt \
            --group-by {params.group_by_state} \
            --sequences-per-group {params.sequences_per_group_state} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        #filter sequences based on continental grouping
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division != '{params.division}' & region == '{params.continental}'" \
            --exclude {input.exclude} \
            --output-strains results/genome/continental_filtered.txt \
            --group-by {params.group_by_continental} \
            --sequences-per-group {params.sequences_per_group_continental} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        #filter sequences based on global grouping
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "region != '{params.continental}'" \
            --exclude {input.exclude} \
            --output-strains results/genome/global_filtered.txt \
            --group-by {params.group_by_global} \
            --sequences-per-group {params.sequences_per_group_global} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        #combine all filtered sequences and include vaccine strains
        augur filter \
            --sequences {input.sequences} \
            --metadata-id-columns {params.strain_id} \
            --metadata {input.metadata} \
            --exclude-all \
            --include results/genome/{params.division}_filtered.txt \
                results/genome/global_filtered.txt \
                results/genome/continental_filtered.txt \
                {input.include} \
            --output-sequences {output.sequences} \
        """
rule filter_N450_state:
    """
    Filtering {params.division} sequences to
      - {params.sequences_per_group_state} sequence(s) per {params.group_by_state!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
    
    Filtering {params.continental} sequences to
      - {params.sequences_per_group_continental} sequence(s) per {params.group_by_continental!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
    """
    input:
        sequences="results/N450/sequences.fasta",
        metadata="data/metadata.tsv",
        exclude=resolve_config_path(config["files"]["exclude"]),
        include=resolve_config_path(config["files"]["include"])({"gene": "N450"}),
    output:
        sequences="results/N450/aligned.fasta"
    params:
        strain_id=config["strain_id_field"],
        division=config["tiers"]["division"],
        continental=config["tiers"]["continental"],
        group_by_state=config["filter_N450"]["group_by_state"],
        group_by_continental=config["filter_N450"]["group_by_continental"],
        group_by_global=config["filter_N450"]["group_by_global"],
        sequences_per_group_global=config["filter_N450"]["sequences_per_group_global"],
        sequences_per_group_state=config["filter_N450"]["sequences_per_group_state"],
        sequences_per_group_continental=config["filter_N450"]["sequences_per_group_continental"],
        min_date=config["filter_N450"]["min_date"],
        min_length=config["filter_N450"]["min_length"]
    # The following shell block performs sequential filtering for division, continental, and global groups,
    # then merges the results with vaccine strains for the final aligned output.
    shell:
        """
        #filter sequences based on division (state)
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division == '{params.division}'" \
            --exclude {input.exclude} \
            --output-strains results/N450/{params.division}_filtered.txt \
            --group-by {params.group_by_state} \
            --sequences-per-group {params.sequences_per_group_state} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        #filter sequences based on continental grouping
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division != '{params.division}' & region == '{params.continental}'" \
            --exclude {input.exclude} \
            --output-strains results/N450/continental_filtered.txt \
            --group-by {params.group_by_continental} \
            --sequences-per-group {params.sequences_per_group_continental} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        #filter sequences based on global grouping
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "region != '{params.continental}'" \
            --exclude {input.exclude} \
            --output-strains results/N450/global_filtered.txt \
            --group-by {params.group_by_global} \
            --sequences-per-group {params.sequences_per_group_global} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        #combine all filtered sequences and include vaccine strains
        augur filter \
            --sequences {input.sequences} \
            --metadata-id-columns {params.strain_id} \
            --metadata {input.metadata} \
            --exclude-all \
            --include results/N450/{params.division}_filtered.txt \
                results/N450/continental_filtered.txt \
                results/N450/global_filtered.txt \
                {input.include} \
            --output-sequences {output.sequences} \
        """
ruleorder: filter_genomic_state > filter
ruleorder: filter_N450_state > filter_N450