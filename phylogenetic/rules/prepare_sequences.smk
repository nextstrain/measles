"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

See Augur's usage docs for these commands for more details.
"""
rule download:
    """Downloading sequences and metadata from data.nextstrain.org"""
    output:
        sequences = "data/sequences.fasta.zst",
        metadata = "data/metadata.tsv.zst"
    params:
        sequences_url = "https://data.nextstrain.org/files/workflows/measles/sequences.fasta.zst",
        metadata_url = "https://data.nextstrain.org/files/workflows/measles/metadata.tsv.zst"
    shell:
        """
        curl -fsSL --compressed {params.sequences_url:q} --output {output.sequences}
        curl -fsSL --compressed {params.metadata_url:q} --output {output.metadata}
        """

rule decompress:
    """Decompressing sequences and metadata"""
    input:
        sequences = "data/sequences.fasta.zst",
        metadata = "data/metadata.tsv.zst"
    output:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv"
    shell:
        """
        zstd -d -c {input.sequences} > {output.sequences}
        zstd -d -c {input.metadata} > {output.metadata}
        """

rule filter:
    """
    Filtering to
      - {params.sequences_per_group} sequence(s) per {params.group_by!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
    """
    input:
        config = resolve_config_path(config["subsample"])({"build": "genome"}),
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv"
    output:
        sequences = "results/genome/filtered.fasta"
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
        sequences = "results/genome/filtered.fasta",
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
