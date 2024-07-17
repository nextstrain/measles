"""
This part of the workflow handles running Nextclade on the curated metadata
and sequences.

See Nextclade docs for more details on usage, inputs, and outputs if you would
like to customize the rules
"""
DATASET_NAME = config["nextclade"]["dataset_name"]


rule get_nextclade_dataset:
    """Download Nextclade dataset"""
    output:
        dataset=f"data/nextclade_data/{DATASET_NAME}.zip",
    params:
        dataset_name=DATASET_NAME
    shell:
        """
        nextclade3 dataset get \
            --name={params.dataset_name:q} \
            --output-zip={output.dataset} \
            --verbose
        """


rule run_nextclade:
    input:
        dataset=f"data/nextclade_data/{DATASET_NAME}.zip",
        sequences="results/sequences.fasta",
    output:
        nextclade="results/nextclade.tsv",
        alignment="results/alignment.fasta",
        translations="results/translations.tar",
    params:
        translations=lambda w: "results/translations/{cds}.fasta",
    shell:
        """
        nextclade3 run \
            {input.sequences} \
            --input-dataset {input.dataset} \
            --output-tsv {output.nextclade} \
            --output-fasta {output.alignment} \
            --output-translations {params.translations}

        tar caf results/translations.tar results/translations
        """


rule join_metadata_and_nextclade:
    input:
        nextclade="results/nextclade.tsv",
        metadata="data/subset_metadata.tsv",
        nextclade_field_map=config["nextclade"]["field_map"],
    output:
        metadata="results/metadata.tsv",
    params:
        metadata_id_field=config["curate"]["output_id_field"],
        nextclade_id_field=config["nextclade"]["id_field"],
    shell:
        """
        export SUBSET_FIELDS=`grep -v '^#' {input.nextclade_field_map} | awk '{{print $1}}' | tr '\n' ',' | sed 's/,$//g'`

        csvtk -tl cut -f $SUBSET_FIELDS \
            {input.nextclade} \
        | csvtk -tl rename2 \
            -F \
            -f '*' \
            -p '(.+)' \
            -r '{{kv}}' \
            -k {input.nextclade_field_map} \
        | tsv-join -H \
            --filter-file - \
            --key-fields {params.nextclade_id_field} \
            --data-fields {params.metadata_id_field} \
            --append-fields '*' \
            --write-all ? \
            {input.metadata} \
        | tsv-select -H --exclude {params.nextclade_id_field} \
            > {output.metadata}
        """    
