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

import yaml
with open("results/run_config.yaml", "w") as f:
    yaml.dump(config, f, sort_keys=False)

rule subsample_genomic:
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
    """
    input:
        config = "results/run_config.yaml",
        sequences="data/sequences.fasta",
        metadata="data/metadata.tsv"
    output:
        sequences="results/genome/filtered.fasta"
    params:
        config_section = ["subsample", "genome"],
        strain_id=config["strain_id_field"]
    # The following shell block performs three sequential filtering steps (division, continental, global)
    # and then combines the filtered results with vaccine strains for the final output.
    shell:
        """
        # Filter sequences based on division
        augur subsample \
            --config {input.config} \
            --config-section {params.config_section:q} \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
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
        config = "results/run_config.yaml",
        sequences="results/N450/sequences.fasta",
        metadata="data/metadata.tsv",
    output:
        sequences="results/N450/aligned.fasta"
    params:
        strain_id=config["strain_id_field"],
        config_section = ["subsample", "N450"],
    # The following shell block performs sequential filtering for division, continental, and global groups,
    # then merges the results with vaccine strains for the final aligned output.
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
ruleorder: subsample_genomic > filter
ruleorder: filter_N450_state > filter_N450