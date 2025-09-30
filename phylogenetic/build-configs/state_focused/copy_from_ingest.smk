rule copy_from_ingest:
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
ruleorder: copy_from_ingest > decompress