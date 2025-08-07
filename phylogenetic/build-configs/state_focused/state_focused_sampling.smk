"""
This file provides custom rules to substitute the default sampling scheme.
These rules will supercede those included in the 'rules' directory
Rule 'filter' applies to the whole-genome dataset.
Rule 'filter_N450' applies to the N450 dataset.
"""
rule filter_genomic_state:
    """
    Filtering {params.division} sequences to
      - {params.sequences_per_group_state} sequence(s) per {params.group_by_state!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
    
    Filtering {params.contextual} sequences to
      - {params.sequences_per_group_contextual} sequence(s) per {params.group_by_contextual!s}
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
        contextual=config["tiers"]["contextual"],
        group_by_state=config["filter"]["group_by_state"],
        group_by_contextual=config["filter"]["group_by_contextual"],
        sequences_per_group_state=config["filter"]["sequences_per_group_state"],
        sequences_per_group_contextual=config["filter"]["sequences_per_group_contextual"],
        min_date=config["filter"]["min_date"],
        min_length=config["filter"]["min_length"]
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division == '{params.division}'" \
            --exclude {input.exclude} \
            --include {input.include} \
            --output-strains results/genome/{params.division}_filtered.txt \
            --group-by {params.group_by_state} \
            --sequences-per-group {params.sequences_per_group_state} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division != '{params.division}'" \
            --exclude {input.exclude} \
            --include {input.include} \
            --output-strains results/genome/{params.contextual}_filtered.txt \
            --group-by {params.group_by_contextual} \
            --sequences-per-group {params.sequences_per_group_contextual} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        augur filter \
        --sequences {input.sequences} \
        --metadata-id-columns {params.strain_id} \
        --metadata {input.metadata} \
        --exclude-all \
        --include results/genome/{params.division}_filtered.txt \
            results/genome/{params.contextual}_filtered.txt \
        --output-sequences {output.sequences} \
        """
rule filter_N450_state:
    """
    Filtering {params.division} sequences to
      - {params.sequences_per_group_state} sequence(s) per {params.group_by_state!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
    
    Filtering {params.contextual} sequences to
      - {params.sequences_per_group_contextual} sequence(s) per {params.group_by_contextual!s}
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
        contextual=config["tiers"]["contextual"],
        group_by_state=config["filter_N450"]["group_by_state"],
        group_by_contextual=config["filter_N450"]["group_by_contextual"],
        sequences_per_group_state=config["filter_N450"]["sequences_per_group_state"],
        sequences_per_group_contextual=config["filter_N450"]["sequences_per_group_contextual"],
        min_date=config["filter_N450"]["min_date"],
        min_length=config["filter_N450"]["min_length"]
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division == '{params.division}'" \
            --exclude {input.exclude} \
            --include {input.include} \
            --output-strains results/N450/{params.division}_filtered.txt \
            --group-by {params.group_by_state} \
            --sequences-per-group {params.sequences_per_group_state} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --query "division != '{params.division}'" \
            --exclude {input.exclude} \
            --include {input.include} \
            --output-strains results/N450/{params.contextual}_filtered.txt \
            --group-by {params.group_by_contextual} \
            --sequences-per-group {params.sequences_per_group_contextual} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        augur filter \
            --sequences {input.sequences} \
            --metadata-id-columns {params.strain_id} \
            --metadata {input.metadata} \
            --exclude-all \
            --include results/N450/{params.division}_filtered.txt \
            results/N450/{params.contextual}_filtered.txt \
            --output-sequences {output.sequences} \
        """
ruleorder: filter_genomic_state > filter
ruleorder: filter_N450_state > filter_N450