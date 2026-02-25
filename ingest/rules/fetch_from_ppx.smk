rule download_ppx_seqs:
    output:
        sequences= "data/ppx_sequences.fasta",
    params:
        sequences_url=lambda w: config["ppx_fetch"]["seqs"],
    # Allow retries in case of network errors
    retries: 5
    shell:
        r"""
        curl -fsSL {params.sequences_url:q} -o {output.sequences}
        """

rule download_ppx_meta:
    output:
        metadata= "data/ppx_metadata.csv"
    params:
        metadata_url=lambda w: config["ppx_fetch"]["meta"],
        fields = ",".join(config["ppx_metadata_fields"])
    # Allow retries in case of network errors
    retries: 5
    shell:
        r"""
        curl -fsSL '{params.metadata_url}&fields={params.fields}' \
        | csvtk mutate2 -n is_reference -e '""' > {output.metadata}
        """

rule format_ppx_ndjson:
    input:
        sequences="data/ppx_sequences.fasta",
        metadata="data/ppx_metadata.csv"
    output:
        ndjson="data/ppx.ndjson"
    log:
        "logs/format_ppx_ndjson.txt"
    shell:
        r"""
        augur curate passthru \
            --metadata {input.metadata} \
            --fasta {input.sequences} \
            --seq-id-column accessionVersion \
            --seq-field sequence \
            --unmatched-reporting warn \
            --duplicate-reporting warn \
            2> logs/format_ppx_ndjson.txt > {output.ndjson}
        """
