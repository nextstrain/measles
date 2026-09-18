"""
This part of the workflow collects the phylobuildtic tree and annotations to
export a Nextstrain dataset.

See Augur's usage docs for these commands for more details.
"""

rule colors:
    """Generate colors from ordering"""
    input:
        ordering = resolve_config_path("defaults/color_ordering.tsv"),
        color_schemes = resolve_config_path("defaults/color_schemes.tsv"),
        metadata = "results/metadata.tsv"
    output:
        colors = "results/colors.tsv"
    log:
        "logs/colors.txt",
    benchmark:
        "benchmarks/colors.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        python3 {workflow.basedir}/scripts/assign-colors.py \
            --ordering {input.ordering} \
            --color-schemes {input.color_schemes} \
            --metadata {input.metadata} \
            --output {output.colors}
        """

def node_data_jsons(wildcards):
    jsons = [
        f"results/{wildcards.build}/branch_lengths.json",
        f"results/{wildcards.build}/nt_muts.json",
        f"results/{wildcards.build}/aa_muts.json",
    ]
    if wildcards.build not in config['traits']:
        raise Exception(f"config.traits must define an entry for build {wildcards.build!r}")
    if config['traits'][wildcards.build] is not False:
        jsons.append(f"results/{wildcards.build}/traits.json",)
    return jsons

rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/{build}/tree.nwk",
        metadata = "results/metadata.tsv",
        node_data_jsons = node_data_jsons,
        colors = "results/colors.tsv",
        config = "results/{build}/export_config.yaml",
        referenced_files = lambda w: get_referenced_files(f"results/{w.build}/export_config.yaml"),
    output:
        auspice_json = "results/auspice/measles/{build}.json"
    params:
        strain_id = config["strain_id_field"],
    log:
        "logs/{build}/export.txt",
    benchmark:
        "benchmarks/{build}/export.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur export v2 \
            --config {input.config} \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --node-data {input.node_data_jsons} \
            --colors {input.colors} \
            --output {output.auspice_json}
        """

rule tip_frequencies:
    """
    Estimating KDE frequencies for tips
    """
    input:
        tree = "results/{build}/tree.nwk",
        metadata = "results/metadata.tsv",
        config = "results/{build}/tip_frequencies_config.yaml",
        referenced_files = lambda w: get_referenced_files(f"results/{w.build}/tip_frequencies_config.yaml"),
    params:
        strain_id = config["strain_id_field"],
    output:
        tip_freq = "results/auspice/measles/{build}_tip-frequencies.json"
    log:
        "logs/{build}/tip_frequencies.txt",
    benchmark:
        "benchmarks/{build}/tip_frequencies.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur frequencies \
            --config {input.config} \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output {output.tip_freq}
        """

rule copy_export:
    input:
        auspice_json = lambda w: f"results/auspice/measles/{w.build_with_underscores.replace('_', '/')}.json",
        tip_freq = lambda w: f"results/auspice/measles/{w.build_with_underscores.replace('_', '/')}_tip-frequencies.json"
    output:
        auspice_json = "auspice/measles_{build_with_underscores}.json",
        tip_freq = "auspice/measles_{build_with_underscores}_tip-frequencies.json"
    shell:
        """
        cp {input.auspice_json} {output.auspice_json}
        cp {input.tip_freq} {output.tip_freq}
        """
