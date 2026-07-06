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
        f"results/{wildcards.gene}/{wildcards.region}/branch_lengths.json",
        f"results/{wildcards.gene}/{wildcards.region}/nt_muts.json",
        f"results/{wildcards.gene}/{wildcards.region}/aa_muts.json",
    ]
    if f"{wildcards.gene}/{wildcards.region}" not in config['traits']:
        raise Exception(f"config.traits must define an entry for '{wildcards.gene}/{wildcards.region}'")
    if config['traits'][f"{wildcards.gene}/{wildcards.region}"] is not None:
        jsons.append(f"results/{wildcards.gene}/{wildcards.region}/traits.json",)
    return jsons

def warning(wildcards):
    if value:=config["export"][f"{wildcards.gene}/{wildcards.region}"].get("warning", False):
        return f"--warning {value!r}"
    return ''

rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/{gene}/{region}/tree.nwk",
        metadata = "results/metadata.tsv",
        node_data_jsons = node_data_jsons,
        colors = "results/colors.tsv",
        auspice_config = resolve_config_path(config["files"]["auspice_config"]),
        description=resolve_config_path(config["files"]["description"])
    output:
        auspice_json = "auspice/measles_{gene}_{region}.json"
    params:
        strain_id = config["strain_id_field"],
        metadata_columns = lambda w: config["export"][f"{w.gene}/{w.region}"]["metadata_columns"],
        warning = warning,
    log:
        "logs/export_{gene}_{region}.txt",
    benchmark:
        "benchmarks/export_{gene}_{region}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --node-data {input.node_data_jsons} \
            --colors {input.colors} \
            --metadata-columns {params.metadata_columns} \
            {params.warning} \
            --auspice-config {input.auspice_config} \
            --include-root-sequence-inline \
            --output {output.auspice_json} \
            --description {input.description}
        """

rule tip_frequencies:
    """
    Estimating KDE frequencies for tips
    """
    input:
        tree = "results/{gene}/{region}/tree.nwk",
        metadata = "results/metadata.tsv"
    params:
        strain_id = config["strain_id_field"],
        min_date = config["tip_frequencies"]["min_date"],
        max_date = config["tip_frequencies"]["max_date"],
        narrow_bandwidth = config["tip_frequencies"]["narrow_bandwidth"],
        wide_bandwidth = config["tip_frequencies"]["wide_bandwidth"]
    output:
        tip_freq = "auspice/measles_{gene}_{region}_tip-frequencies.json"
    log:
        "logs/tip_frequencies_{gene}_{region}.txt",
    benchmark:
        "benchmarks/tip_frequencies_{gene}_{region}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur frequencies \
            --method kde \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --min-date {params.min_date} \
            --max-date {params.max_date} \
            --narrow-bandwidth {params.narrow_bandwidth} \
            --wide-bandwidth {params.wide_bandwidth} \
            --output {output.tip_freq}
        """
