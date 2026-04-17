"""
This part of the workflow constructs the phylogenetic tree.

See Augur's usage docs for these commands for more details.
"""

rule tree:
    """Building tree"""
    input:
        alignment = "results/{build}/aligned.fasta"
    output:
        tree = "results/{build}/tree_raw.nwk"
    log:
        "logs/tree_{build}.txt",
    benchmark:
        "benchmarks/tree_{build}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur tree \
            --alignment {input.alignment} \
            --output {output.tree}
        """

def _get_refine_param(wildcards, param_name):
    """
    Get refine param in a backwards compatible manner. Config can define:
    1. params for all builds (old)

        refine:
            <param_name>: ...

    2. build specific params (new)

        refine:
            <build>:
                <param_name>: ...
    """
    # Check for the old format first so that users don't need to update their
    # configs unless they want to
    if (all_build_param := config["refine"].get(param_name)) is not None:
        return all_build_param

    # Check build key before the inner param_name to support build nullification, e.g.
    #     refine:
    #         N450: ~
    if (build_params := config["refine"].get(wildcards.build)) is not None:
        if (param := build_params.get(param_name)) is not None:
            return param

    raise Exception(f"Could not parse config param {param_name!r} for refine rule.",
                    f"It should be defined as `refine.{param_name}` or `refine.{wildcards.build}.{param_name}`")


rule refine:
    """
    Refining tree
      - estimate timetree
      - use {params.coalescent} coalescent timescale
      - estimate {params.date_inference} node dates
      - filter tips more than {params.clock_filter_iqd} IQDs from clock expectation
    """
    input:
        tree = "results/{build}/tree_raw.nwk",
        alignment = "results/{build}/aligned.fasta",
        metadata = "results/metadata.tsv"
    output:
        tree = "results/{build}/tree.nwk",
        node_data = "results/{build}/branch_lengths.json"
    params:
        coalescent = lambda w: _get_refine_param(w, "coalescent"),
        date_inference = lambda w: _get_refine_param(w, "date_inference"),
        clock_filter_iqd = lambda w: _get_refine_param(w, "clock_filter_iqd"),
        strain_id = config["strain_id_field"]
    log:
        "logs/refine_{build}.txt",
    benchmark:
        "benchmarks/refine_{build}.txt",
    shell:
        r"""
        exec &> >(tee {log:q})

        augur refine \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output-tree {output.tree} \
            --output-node-data {output.node_data} \
            --timetree \
            --coalescent {params.coalescent} \
            --date-confidence \
            --date-inference {params.date_inference} \
            --clock-filter-iqd {params.clock_filter_iqd} \
            --stochastic-resolve
        """
