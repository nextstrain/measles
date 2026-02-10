"""
This part of the workflow handles running Nextclade on the curated metadata
and sequences.

See Nextclade docs for more details on usage, inputs, and outputs if you would
like to customize the rules
"""
import sys

DATASET_NAME = config["nextclade"]["dataset_name"]


rule get_nextclade_dataset:
    """Download Nextclade dataset"""
    output:
        dataset=f"data/nextclade_data/{DATASET_NAME}.zip",
    params:
        dataset_name=DATASET_NAME
    benchmark:
        "benchmarks/get_nextclade_dataset.txt"
    log:
        "logs/get_nextclade_dataset.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        nextclade3 dataset get \
            --name={params.dataset_name:q} \
            --output-zip={output.dataset:q} \
            --verbose
        """


rule run_nextclade:
    input:
        dataset=f"data/nextclade_data/{DATASET_NAME}.zip",
        sequences="results/sequences.fasta",
    output:
        nextclade="results/nextclade.tsv",
        alignment="results/alignment.fasta",
        translations="results/translations.zip",
    params:
        # The lambda is used to deactivate automatic wildcard expansion.
        # https://github.com/snakemake/snakemake/blob/384d0066c512b0429719085f2cf886fdb97fd80a/snakemake/rules.py#L997-L1000
        translations=lambda w: "results/translations/{cds}.fasta",
    benchmark:
        "benchmarks/run_nextclade.txt"
    log:
        "logs/run_nextclade.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        nextclade3 run \
            {input.sequences:q} \
            --input-dataset {input.dataset:q} \
            --output-tsv {output.nextclade:q} \
            --output-fasta {output.alignment:q} \
            --output-translations {params.translations:q}

        zip -rj {output.translations:q} results/translations
        """


if isinstance(config["nextclade"]["field_map"], str):
    print(f"Converting config['nextclade']['field_map'] from TSV file ({config['nextclade']['field_map']}) to dictionary; "
          f"consider putting the field map directly in the config file.", file=sys.stderr)

    with open(config["nextclade"]["field_map"], "r") as f:
        config["nextclade"]["field_map"] = dict(line.rstrip("\n").split("\t", 1) for line in f if not line.startswith("#"))


rule nextclade_metadata:
    input:
        nextclade="results/nextclade.tsv",
    output:
        nextclade_metadata=temp("results/nextclade_metadata.tsv"),
    params:
        nextclade_id_field=config["nextclade"]["id_field"],
        nextclade_field_map=[f"{old}={new}" for old, new in config["nextclade"]["field_map"].items()],
        nextclade_fields=",".join(config["nextclade"]["field_map"].values()),
    benchmark:
        "benchmarks/nextclade_metadata.txt"
    log:
        "logs/nextclade_metadata.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur curate rename \
            --metadata {input.nextclade:q} \
            --id-column {params.nextclade_id_field:q} \
            --field-map {params.nextclade_field_map:q} \
            --output-metadata - \
        | csvtk cut -t --fields {params.nextclade_fields:q} \
        > {output.nextclade_metadata:q}
        """


rule join_metadata_and_nextclade:
    input:
        metadata="data/subset_metadata.tsv",
        nextclade_metadata="results/nextclade_metadata.tsv",
    output:
        metadata="results/metadata.tsv",
    params:
        metadata_id_field=config["curate"]["output_id_field"],
        nextclade_id_field=config["nextclade"]["id_field"],
    benchmark:
        "benchmarks/join_metadata_and_nextclade.txt"
    log:
        "logs/join_metadata_and_nextclade.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --metadata \
                metadata={input.metadata:q} \
                nextclade={input.nextclade_metadata:q} \
            --metadata-id-columns \
                metadata={params.metadata_id_field:q} \
                nextclade={params.nextclade_id_field:q} \
            --output-metadata {output.metadata:q} \
            --no-source-columns
        """

rule extract_ppx_data:
    input:
        metadata = "results/metadata.tsv",
        sequences = "results/sequences.fasta"
    output:
        metadata = "results/metadata_{ppx_dut}.tsv",
        sequences = "results/sequences_{ppx_dut}.fasta"
    wildcard_constraints:
        ppx_dut="open|restricted",
    params:
        ppx_dut = lambda w: w.ppx_dut.upper(),
        # Warn on empty output for restricted since it's feasible that
        # none of the data is restricted
        empty_output = lambda w: "warn" if w.ppx_dut == "restricted" else "error",
    shell:
        """
        augur filter --metadata {input.metadata} \
                     --sequences {input.sequences} \
                     --metadata-id-columns accession \
                     --exclude-all \
                     --include-where "dataUseTerms={params.ppx_dut:q}" \
                     --output-metadata {output.metadata} \
                     --output-sequences {output.sequences} \
                     --empty-output-reporting {params.empty_output:q}
        """
