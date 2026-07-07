# Multi-Dataset Workflow Configuration

This document specifies the behavior of the modular configuration parsing, validation, and pattern-matching system designed for use across pathogen workflows. This system parses hierarchical, pattern-based configurations into specific command configurations for datasets.

## Dataset Structure

A **Dataset** is defined by a slash-delimited (`/`) sequence of values, where each value corresponds to a specific workflow category or level. 

For example, in the dataset `genome/global`:
- `genome` is the value for the `gene_or_genome` level.
- `global` is the value for the `region` level.

The names and valid values for each level are defined in the `dataset_levels` configuration key.

---

## Dataset Patterns

Dataset patterns follow the same format as datasets (a slash-delimited sequence of values) and support additional wildcard and multivalue syntax to target rules to one or more datasets. Because it is a superset, simple configurations that map datasets directly to configurations (without any wildcards or multivalues) remain completely valid.

### Pattern Syntax
- **Literal**: Matches exactly the specified string value, e.g. `genome/global`.
- **Wildcard**: `*` matches any value at this level, e.g. `*/global`.
- **Multivalue**: A parenthesized, pipe-separated list matches any value inside it, e.g. `(genome|N450)/global`.

---

## Rule Schema Principle

Each dataset pattern in a rule's configuration maps to a value (dict) representing the config schema used for the rule's underlying command (e.g., `subsample` options, `refine` options).

---

## Merging Configurations

Because a single dataset name can match multiple patterns of varying specificity, multiple matching pattern configurations are merged when generating configuration for a specific rule and dataset.

### Resolution Steps
1. **Pattern Selection**:
   All pattern keys in the active configuration block are matched against the target dataset.
2. **Value Merging**:
   The matched configurations are merged sequentially in definition order (i.e., later definitions take priority).
   
   To remain consistent with Snakemake's config merging behavior:
   - **Mappings (Dictionaries)** are merged recursively.
   - **Scalars and Lists** overwrite prior values.
   
   The following features are not used by Snakemake but are used here:
   - **Dict Copying**: New dictionaries are deep-copied from the override to prevent mutating the source config.
   - **Null-Deletion Support**: If a key in an override configuration maps to a `null` value, that key is completely deleted from the base configuration. For example:
     ```yaml
     # A broad pattern sets defaults for all datasets
     */*:
       samples:
         early:
           max_sequences: 2000
         late:
           max_sequences: 2000
     # A specific pattern deletes the 'early' sample group
     genome/global:
       samples:
         early: null
     ```
3. **Custom Overrides (Starting from Scratch)**:
   A custom override block is a top-level configuration block named `custom_<rule_name>` (e.g., `custom_subsample` for the `subsample` rule). If present, the custom override block completely overrides the standard configuration block for that rule and the configuration is resolved solely from the custom block. This allows configurations to "start from scratch" rather than merging recursively on top of standard configurations.

---

## Validation

Before configs are generated, the system performs strict validation:
- **Structure**: Rule configurations must be a dictionary mapping patterns to configurations.
- **Pattern Match Count**: The number of parts in each pattern must exactly match the number of defined dataset levels.
- **Value Constraints**: Non-wildcard pattern values must belong to the valid values defined for that level.

---

## Output Generation

For each target dataset and each configured rule (i.e. per dataset × per rule), the system generates a separate configuration file:
- **Path**: `<output_dir>/<dataset_name>/<rule_name>_config.yaml`
  *(e.g., `results/genome/global/subsample_config.yaml`)*
- **Format**: YAML with an added header comment indicating the dataset identifier (e.g., `# genome/global`).
- **Post-processing**: Rules can apply post-processing (e.g., merging default values for `subsample`).

Because each dataset pattern maps to a value matching the rule's command schema, the generated output file is a fully resolved version of that schema. Users can easily copy a generated output file and paste it directly back into their top-level config file under a specific pattern or override block to adjust config parameters from a complete, fully resolved baseline.
