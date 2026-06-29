rule update_example_data:
    input:
        sequences="results/sequences.fasta",
        metadata="results/metadata.tsv",
    output:
        sequences="example_data/sequences.fasta",
        metadata="example_data/metadata.tsv",
    params:
        strain_id=config["strain_id_field"],
    shell:
        r"""
        augur filter \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --sequences {input.sequences} \
            --subsample-max-sequences 50 \
            --group-by month \
            --subsample-seed 0 \
            --include defaults/include_strains_genome.txt \
            --output-metadata {output.metadata} \
            --output-sequences {output.sequences}
        """
