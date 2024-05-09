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

rule align_and_extract_N450:
    input:
        sequences = "data/sequences.fasta",
        reference = config["files"]["reference_N450_fasta"]
    output:
        sequences = "results/sequences_N450.fasta"
    params:
        min_seed_cover = config['align_and_extract_N450']['min_seed_cover'],
        min_length = config['align_and_extract_N450']['min_length']
    threads: workflow.cores
    shell:
        """
        nextclade3 run \
           --jobs {threads} \
           --input-ref {input.reference} \
           --output-fasta {output.sequences} \
           --min-seed-cover {params.min_seed_cover} \
           --min-length {params.min_length} \
           --silent \
           {input.sequences}
        """

rule filter:
    input:
        sequences = "results/sequences_N450.fasta",
        metadata = "data/metadata.tsv",
        exclude = config["files"]["exclude"],
        include = config["files"]["include"]
    output:
        sequences = "results/aligned.fasta"
    params:
        group_by = config["filter"]["group_by"],
        subsample_max_sequences = config["filter"]["subsample_max_sequences"],
        min_date = config["filter"]["min_date"],
        min_length = config["filter"]["min_length"],
        strain_id = config["strain_id_field"]
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --exclude {input.exclude} \
            --include {input.include} \
            --output {output.sequences} \
            --group-by {params.group_by} \
            --subsample-max-sequences {params.subsample_max_sequences} \
            --min-date {params.min_date} \
            --min-length {params.min_length} \
            --query='genotype_ncbi!=""'
        """
