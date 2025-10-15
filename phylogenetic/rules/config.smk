"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/config_raw.yaml
    results/config_processed.yaml
"""
from copy import deepcopy


def main():
    global config

    config = load_config()

    # Dump the unmodified config to a YAML file.
    write_config("results/config_raw.yaml")

    process_subsample_config()

    # Move user config to its own section.
    config = {
        "WORKFLOW_CONFIG": {},
        "USER_CONFIG": deepcopy(config),
    }

    # NOTE: Unlike shared/config.smk:resolve_config_path() which does both
    # "resolve wildcards" and "resolve filepaths", I chose to separate the two
    # concerns here because the latter may be handled by Augur¹.
    # ¹ "Additional notes" section in https://github.com/nextstrain/augur/issues/1897
    restructure_and_resolve_wildcards()
    resolve_filepaths([
        ("WORKFLOW_CONFIG", "*", "align_genome", "reference"),
        ("WORKFLOW_CONFIG", "*", "align_and_extract_N450", "reference_fasta"),
        ("WORKFLOW_CONFIG", "*", "translate", "reference"),
        ("WORKFLOW_CONFIG", "*", "export", "colors"),
        ("WORKFLOW_CONFIG", "*", "export", "description"),
        ("WORKFLOW_CONFIG", "*", "export", "auspice_config"),
    ])

    # Write the modified config to a file.
    write_config("results/config_processed.yaml")

    # Write subsample configuration files.
    # Do this outside of a rule to take advantage of Snakemake's file change detection.
    for build in get_builds():
        section = ["WORKFLOW_CONFIG", build, "subsample", "config"]
        write_config(f"results/{build}/subsample_config.yaml", section=section)


def restructure_and_resolve_wildcards():
    """Populate WORKFLOW_CONFIG into a standardized format for internal usage.

    Format is:

    WORKFLOW_CONFIG:
      <build>:
        <rule>:
          <config>

    Wildcards in config values (i.e. string placeholders) are resolved in this
    function.

    NOTE: The term 'wildcards' is used as an analogy to Snakemake's wildcards
    feature - the implementation here is somewhat separate from that feature.
    """

    global config

    user_config = config["USER_CONFIG"]

    for build in user_config['builds']:
        config["WORKFLOW_CONFIG"][build] = {}
        build_config = config["WORKFLOW_CONFIG"][build]
        wildcards = {"build": build}

        if build == "genome":
            build_config["align_genome"] = {
                "reference": apply_wildcards(user_config["files"]["reference"], wildcards)
            }
        elif build == "N450":
            build_config["align_and_extract_N450"] = {
                "min_length": user_config["align_and_extract_N450"]["min_length"],
                "reference_fasta": apply_wildcards(user_config["files"]["reference_fasta"], wildcards)
            }

        # FIXME: subsample_genome vs. subsample_N450?
        build_config["subsample"] = {
            "strain_id_field": user_config["strain_id_field"],
            "config": user_config["subsample"][build]
        }

        build_config["refine"] = {
            **user_config["refine"],
            "strain_id_field": user_config["strain_id_field"],
        }

        build_config["ancestral"] = {
            **user_config["ancestral"],
        }

        build_config["translate"] = {
            "reference": apply_wildcards(user_config["files"]["reference"], wildcards),
        }

        build_config["tip_frequencies"] = {
            **user_config["tip_frequencies"],
            "strain_id_field": user_config["strain_id_field"],
        }

        build_config["export"] = {
            **user_config["export"],
            "strain_id_field": user_config["strain_id_field"],
            "colors": user_config["files"]["colors"],
            "description": user_config["files"]["description"],
            "auspice_config": apply_wildcards(user_config["files"]["auspice_config"], wildcards),
        }


def get_config_value(*keys):
    """
    Return a callable to retrieve a config value from WORKFLOW_CONFIG given wildcards.
    """
    def _get(wildcards):
        build = wildcards.build if hasattr(wildcards, 'build') else wildcards["build"]
        result = config["WORKFLOW_CONFIG"][build]
        for key in keys:
            result = result[key]
        return result
    return _get


def get_builds():
    return config['WORKFLOW_CONFIG'].keys()


main()
