import os
os.environ["AUGUR_RECURSION_LIMIT"] = str(5000)

rule all:
    input:
        auspice_tree = "auspice/measles_{genogroup}_{segment}_tree.json",
        auspice_meta = "auspice/measles_{genogroup}_{segment}_meta.json"

input_fasta = "data/sequences_{genogroup}_{segment}.fasta",
input_meta = "data/metadata_{genogroup}_{segment}.csv",
dropped_strains = "config/dropped_strains_{genogroup}_{segment}.txt",
reference = "config/measles_reference_{segment}.gb",
colors = "config/colors.tsv",
auspice_config = "config/auspice_config.json"

def get_min_length(w):
    return 5000 if w.segment=='genome' else 300

def get_rate(w):
    return 0.0005 if w.segment=='genome' else 0.0007


rule download:
    message: "Downloading sequences from fauna"
    output:
        sequences = "data/measles_fauna_{genogroup}_{segment}.fasta"
    params:
        fasta_fields = "strain virus accession collection_date region country division location source locus authors url title journal puburl"
    shell:
        """
        python3 ../fauna/vdb/download.py \
            --database vdb \
            --virus measles \
            --fasta_fields {params.fasta_fields} \
            --resolve_method choose_genbank \
            --path $(dirname {output.sequences}) \
            --fstem $(basename {output.sequences} .fasta)
        """

rule parse:
    message: "Parsing fasta into sequences and metadata"
    input:
        sequences = rules.download.output.sequences
    output:
        sequences = input_fasta,
        metadata = input_meta
    params:
        fasta_fields = "strain virus accession date region country division city db segment authors url title journal paper_url"
    shell:
        """
        augur parse \
            --sequences {input.sequences} \
            --output-sequences {output.sequences} \
            --output-metadata {output.metadata} \
            --fields {params.fasta_fields}
        """

rule filter:
    message:
        """
        Filtering to
          - {params.sequences_per_group} sequence(s) per {params.group_by!s}
          - from {params.min_date} onwards
          - excluding strains in {input.exclude}
          - minimum genome length of {params.min_length}
        """
    input:
        sequences = rules.parse.output.sequences,
        metadata = rules.parse.output.metadata,
        exclude = dropped_strains
    output:
        sequences = "results/filtered_{genogroup}_{segment}.fasta"
    params:
        group_by = "country year month",
        sequences_per_group = 10,
        min_date = 1950,
        min_length = get_min_length
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --exclude {input.exclude} \
            --output {output.sequences} \
            --group-by {params.group_by} \
            --sequences-per-group {params.sequences_per_group} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        """

rule align:
    message:
        """
        Aligning sequences to {input.reference}
          - filling gaps with N
        """
    input:
        sequences = rules.filter.output.sequences,
        reference = reference
    output:
        alignment = "results/aligned_{genogroup}_{segment}.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference
        """

rule tree:
    message: "Building tree"
    input:
        alignment = rules.align.output.alignment
    output:
        tree = "results/tree-raw_{genogroup}_{segment}.nwk"
    shell:
        """
        augur tree \
            --alignment {input.alignment} \
            --output {output.tree}
        """

rule refine:
    message:
        """
        Refining tree
          - estimate timetree
          - use {params.coalescent} coalescent timescale
          - estimate {params.date_inference} node dates
          - filter tips more than {params.clock_filter_iqd} IQDs from clock expectation
        """
    input:
        tree = rules.tree.output.tree,
        alignment = rules.align.output,
        metadata = rules.parse.output.metadata
    output:
        tree = "results/tree_{genogroup}_{segment}.nwk",
        node_data = "results/branchlengths_{genogroup}_{segment}.json"
    params:
        coalescent = "opt",
        date_inference = "marginal",
        clock_filter_iqd = 4,
        clock_rate = get_rate,
        clock_std_dev = 0.00005
    shell:
        """
        augur refine \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --metadata {input.metadata} \
            --output-tree {output.tree} \
            --output-node-data {output.node_data} \
            --timetree \
            --coalescent {params.coalescent} \
            --date-confidence \
            --clock-rate {params.clock_rate} \
            --clock-std-dev {params.clock_std_dev} \
            --date-inference {params.date_inference} \
            --clock-filter-iqd {params.clock_filter_iqd}
        """

rule ancestral:
    message: "Reconstructing ancestral sequences and mutations"
    input:
        tree = rules.refine.output.tree,
        alignment = rules.align.output
    output:
        node_data = "results/ntmuts_{genogroup}_{segment}.json"
    params:
        inference = "joint"
    shell:
        """
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output {output.node_data} \
            --inference {params.inference}
        """

rule translate:
    message: "Translating amino acid sequences"
    input:
        tree = rules.refine.output.tree,
        node_data = rules.ancestral.output.node_data,
        reference = reference
    output:
        node_data = "results/aamuts_{genogroup}_{segment}.json"
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --ancestral-sequences {input.node_data} \
            --reference-sequence {input.reference} \
            --output {output.node_data} \
        """

rule export:
    message: "Exporting data files for for auspice"
    input:
        tree = rules.refine.output.tree,
        metadata = rules.parse.output.metadata,
        branch_lengths = rules.refine.output.node_data,
        nt_muts = rules.ancestral.output.node_data,
        aa_muts = rules.translate.output.node_data,
        colors = colors,
        auspice_config = auspice_config
    output:
        auspice_tree = rules.all.input.auspice_tree,
        auspice_meta = rules.all.input.auspice_meta
    shell:
        """
        augur export \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.branch_lengths} {input.nt_muts} {input.aa_muts} \
            --colors {input.colors} \
            --minify-json \
            --extra-traits country region subtype \
            --auspice-config {input.auspice_config} \
            --output-tree {output.auspice_tree} \
            --output-meta {output.auspice_meta}
        """

rule clean:
    message: "Removing directories: {params}"
    params:
        "results ",
        "auspice"
    shell:
        "rm -rfv {params}"
