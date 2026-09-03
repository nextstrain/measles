<!-- [DO NOT EDIT] This file was automatically generated. -->
# Configuration Reference

This reference is automatically generated.

## Top-Level Settings

This is the schema for the Nextstrain measles phylogenetic workflow's configuration file.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `builds` | `string \| array` | `["genome/global", "N450/global", "genome/north-america"]` | - |
| `custom_rules` | `list[string]` | - | Custom Snakemake rule files to include. If used, this will disable config schema validation. |
| `nextclade` | `object` | (2 entries) | Map of gene name strings (e.g. 'genome' or 'N450') to argument strings. |
| `strain_id_field` | `string` | `accession` | - |

### `additional_inputs[]`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `additional_inputs[].metadata` | `string` | - | - |
| `additional_inputs[].name` | `string` | - | - |
| `additional_inputs[].sequences` | `string` | - | - |

### `ancestral`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `ancestral.inference` | `string` | `joint` | - |

### `custom_refine.<build>`

Custom refine configuration. When using --configfile, this can be used instead of 'refine' to ignore default refine configuration.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `custom_refine.<build>.branch_length_inference` | `"auto" \| "joint" \| "marginal" \| "input"` | `auto` | branch length mode of treetime to use |
| `custom_refine.<build>.clock_filter_iqd` | `number` | - | clock-filter: remove tips that deviate more than n_iqd interquartile ranges from the root-to-tip vs time regression |
| `custom_refine.<build>.clock_rate` | `number` | - | fixed clock rate |
| `custom_refine.<build>.clock_std_dev` | `number` | - | standard deviation of the fixed clock_rate estimate |
| `custom_refine.<build>.coalescent` | `string` | - | coalescent time scale in units of inverse clock rate (float), optimize as scalar ('opt'), or skyline ('skyline') |
| `custom_refine.<build>.covariance` | `boolean` | `true` | Account for covariation when estimating rates and/or rerooting. In CLI, use --no-covariance to turn off. In a YAML config file, set to False to turn off. |
| `custom_refine.<build>.date_confidence` | `boolean` | `false` | calculate confidence intervals for node dates |
| `custom_refine.<build>.date_format` | `string` | `%Y-%m-%d` | date format |
| `custom_refine.<build>.date_inference` | `"joint" \| "marginal"` | `joint` | assign internal nodes to their marginally most likely dates, not jointly most likely |
| `custom_refine.<build>.divergence_units` | `"mutations" \| "mutations-per-site"` | `mutations-per-site` | Units in which sequence divergences is exported. |
| `custom_refine.<build>.gen_per_year` | `number` | `50` | number of generations per year, relevant for skyline output('skyline') |
| `custom_refine.<build>.greedy_resolve` | `boolean` | - | - |
| `custom_refine.<build>.keep_ids` | `string` | - | file containing ids to keep in tree regardless of clock filtering (one per line) |
| `custom_refine.<build>.keep_polytomies` | `boolean` | `false` | Do not attempt to resolve polytomies |
| `custom_refine.<build>.keep_root` | `boolean` | `false` | do not reroot the tree; use it as-is. Overrides anything specified by '--root'/'root'. |
| `custom_refine.<build>.max_iter` | `integer` | `2` | maximal number of iterations TreeTime uses for timetree inference |
| `custom_refine.<build>.precision` | `"0" \| "1" \| "2" \| "3"` | - | precision used by TreeTime to determine the number of grid points that are used for the evaluation of the branch length interpolation objects. Values range from 0 (rough) to 3 (ultra fine) and default to 'auto'. |
| `custom_refine.<build>.remove_outgroup` | `boolean` | `false` | Remove the outgroup supplied via '--root'/'root'. This is only valid when a single strain name has been supplied as the root. |
| `custom_refine.<build>.root` | `list[string]` | `["best"]` | rooting mechanism ('best', 'least-squares', 'min_dev', 'oldest', 'mid_point') OR node to root by OR two nodes indicating a monophyletic group to root by. Run treetime -h for definitions of rooting methods. |
| `custom_refine.<build>.seed` | `integer` | - | seed for random number generation |
| `custom_refine.<build>.seq_type` | `"nuc" \| "aa"` | `nuc` | Sequence type: 'nuc' or 'aa' |
| `custom_refine.<build>.stochastic_resolve` | `boolean` | `false` | Resolve polytomies via stochastic subtree building rather than greedy optimization |
| `custom_refine.<build>.timetree` | `boolean` | `false` | produce timetree using treetime, requires tree where branch length is in units of average number of nucleotide or protein substitutions per site (and branch lengths do not exceed 4) |
| `custom_refine.<build>.use_fft` | `boolean` | `false` | produce timetree using FFT for convolutions |
| `custom_refine.<build>.vcf_reference` | `string` | - | fasta file of the sequence the VCF was mapped to |
| `custom_refine.<build>.verbosity` | `integer` | `1` | treetime verbosity, between 0 and 6 (higher values more output) |
| `custom_refine.<build>.year_bounds` | `list[integer]` | - | specify min or max & min prediction bounds for samples with XX in year |

#### `custom_subsample.<key>.defaults`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `custom_subsample.<key>.defaults.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `custom_subsample.<key>.defaults.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `custom_subsample.<key>.defaults.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `custom_subsample.<key>.defaults.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `custom_subsample.<key>.defaults.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `custom_subsample.<key>.defaults.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<key>.defaults.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<key>.defaults.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<key>.defaults.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<key>.defaults.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<key>.defaults.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<key>.defaults.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `custom_subsample.<key>.defaults.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `custom_subsample.<key>.defaults.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |

#### `custom_subsample.<key>.samples.<key>`

One of: filterSampleProperties, proximalSampleProperties. Not all properties below apply to every variant.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `custom_subsample.<key>.samples.<key>.context_sample` | `string` | - | Use the outputs from another sample as the inputs for this sample. Value must be a sample name. |
| `custom_subsample.<key>.samples.<key>.drop_sample` | `boolean` | - | Drop this sample from the final output |
| `custom_subsample.<key>.samples.<key>.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `custom_subsample.<key>.samples.<key>.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `custom_subsample.<key>.samples.<key>.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `custom_subsample.<key>.samples.<key>.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `custom_subsample.<key>.samples.<key>.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `custom_subsample.<key>.samples.<key>.focal_sample` | `string` | - | FASTA file with aligned focal sequences to find neighbors for |
| `custom_subsample.<key>.samples.<key>.group_by` | `object` | - | Grouping columns for subsampling. Notes:  (1) Grouping by ['month', 'week', 'year'] is only     supported when there is a 'date' column in the     metadata. (2) 'week' uses the ISO week numbering system, where a week starts on a     Monday and ends on a Sunday. (3) 'month' and 'week' grouping cannot be used together. (4) Custom columns ['month', 'week', 'year'] in the     metadata are ignored for grouping. Please rename them if you want to     use their values for grouping. |
| `custom_subsample.<key>.samples.<key>.group_by_weights` | `string` | - | TSV file defining weights for grouping. Requirements:  (1) Lines starting with '#' are treated as comment lines. (2) The first non-comment line must be a header row. (3) There must be a numeric ``weight`` column (weights can take on any     non-negative values). (4) Other columns must be a subset of grouping columns, with     combinations of values covering all combinations present in the     metadata. (5) This option only applies when grouping columns and a total sample     size are provided. (6) This option can only be used when probabilistic sampling is allowed.  Notes:  (1) Any grouping columns absent from this file will be given equal     weighting across all values *within* groups defined by the other     weighted columns. (2) An entry with the value ``default`` under all columns will be     treated as the default weight for specific groups present in the     metadata but missing from the weights file. If there is no default     weight and the metadata contains rows that are not covered by the     given weights, augur filter will exit with an error. |
| `custom_subsample.<key>.samples.<key>.ignore_missing_data` | `string` | - | All non-ATGC bases are converted to 'N', and then: - 'none' treats 'N' as a normal base for comparison purposes; - 'all' ignores positions where either sequence is N; - 'flanking' ignores runs of Ns at the start/end of each sequence. |
| `custom_subsample.<key>.samples.<key>.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<key>.samples.<key>.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<key>.samples.<key>.k` | `integer` | - | number of nearest neighbors to find per focal strain |
| `custom_subsample.<key>.samples.<key>.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<key>.samples.<key>.max_distance` | `integer` | - | maximum distance threshold for considering a sequence to match |
| `custom_subsample.<key>.samples.<key>.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<key>.samples.<key>.max_sequences` | `integer` | - | Select no more than this number of sequences (i.e. total sample size). Can be used without grouping columns. |
| `custom_subsample.<key>.samples.<key>.method` | `"hamming"` | - | Proximity approach used |
| `custom_subsample.<key>.samples.<key>.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<key>.samples.<key>.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<key>.samples.<key>.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `custom_subsample.<key>.samples.<key>.probabilistic_sampling` | `boolean` | - | Allow probabilistic sampling during subsampling. This is useful when there are more groups than requested sequences. This option only applies when a total sample size is provided. |
| `custom_subsample.<key>.samples.<key>.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `custom_subsample.<key>.samples.<key>.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |
| `custom_subsample.<key>.samples.<key>.sequences_per_group` | `integer` | - | Select no more than this number of sequences per category. |

### `export.<key>`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `export.<key>.metadata_columns` | `string` | - | - |
| `export.<key>.warning` | `string` | - | - |

### `files`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `files.auspice_config` | `string` | `auspice_config/{build}.json` | - |
| `files.description` | `string` | `description.md` | - |
| `files.reference` | `string` | `measles_reference_{gene}.gb` | - |
| `files.reference_fasta` | `string` | `measles_reference_{gene}.fasta` | - |

### `inputs[]`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `inputs[].metadata` | `string` | - | - |
| `inputs[].name` | `string` | - | - |
| `inputs[].sequences` | `string` | - | - |

### `refine.<build>`

Refine configuration. You may also use 'custom_refine' instead to ignore default configuration.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `refine.<build>.branch_length_inference` | `"auto" \| "joint" \| "marginal" \| "input"` | `auto` | branch length mode of treetime to use |
| `refine.<build>.clock_filter_iqd` | `number` | - | clock-filter: remove tips that deviate more than n_iqd interquartile ranges from the root-to-tip vs time regression |
| `refine.<build>.clock_rate` | `number` | - | fixed clock rate |
| `refine.<build>.clock_std_dev` | `number` | - | standard deviation of the fixed clock_rate estimate |
| `refine.<build>.coalescent` | `string` | - | coalescent time scale in units of inverse clock rate (float), optimize as scalar ('opt'), or skyline ('skyline') |
| `refine.<build>.covariance` | `boolean` | `true` | Account for covariation when estimating rates and/or rerooting. In CLI, use --no-covariance to turn off. In a YAML config file, set to False to turn off. |
| `refine.<build>.date_confidence` | `boolean` | `false` | calculate confidence intervals for node dates |
| `refine.<build>.date_format` | `string` | `%Y-%m-%d` | date format |
| `refine.<build>.date_inference` | `"joint" \| "marginal"` | `joint` | assign internal nodes to their marginally most likely dates, not jointly most likely |
| `refine.<build>.divergence_units` | `"mutations" \| "mutations-per-site"` | `mutations-per-site` | Units in which sequence divergences is exported. |
| `refine.<build>.gen_per_year` | `number` | `50` | number of generations per year, relevant for skyline output('skyline') |
| `refine.<build>.greedy_resolve` | `boolean` | - | - |
| `refine.<build>.keep_ids` | `string` | - | file containing ids to keep in tree regardless of clock filtering (one per line) |
| `refine.<build>.keep_polytomies` | `boolean` | `false` | Do not attempt to resolve polytomies |
| `refine.<build>.keep_root` | `boolean` | `false` | do not reroot the tree; use it as-is. Overrides anything specified by '--root'/'root'. |
| `refine.<build>.max_iter` | `integer` | `2` | maximal number of iterations TreeTime uses for timetree inference |
| `refine.<build>.precision` | `"0" \| "1" \| "2" \| "3"` | - | precision used by TreeTime to determine the number of grid points that are used for the evaluation of the branch length interpolation objects. Values range from 0 (rough) to 3 (ultra fine) and default to 'auto'. |
| `refine.<build>.remove_outgroup` | `boolean` | `false` | Remove the outgroup supplied via '--root'/'root'. This is only valid when a single strain name has been supplied as the root. |
| `refine.<build>.root` | `list[string]` | `["best"]` | rooting mechanism ('best', 'least-squares', 'min_dev', 'oldest', 'mid_point') OR node to root by OR two nodes indicating a monophyletic group to root by. Run treetime -h for definitions of rooting methods. |
| `refine.<build>.seed` | `integer` | - | seed for random number generation |
| `refine.<build>.seq_type` | `"nuc" \| "aa"` | `nuc` | Sequence type: 'nuc' or 'aa' |
| `refine.<build>.stochastic_resolve` | `boolean` | `false` | Resolve polytomies via stochastic subtree building rather than greedy optimization |
| `refine.<build>.timetree` | `boolean` | `false` | produce timetree using treetime, requires tree where branch length is in units of average number of nucleotide or protein substitutions per site (and branch lengths do not exceed 4) |
| `refine.<build>.use_fft` | `boolean` | `false` | produce timetree using FFT for convolutions |
| `refine.<build>.vcf_reference` | `string` | - | fasta file of the sequence the VCF was mapped to |
| `refine.<build>.verbosity` | `integer` | `1` | treetime verbosity, between 0 and 6 (higher values more output) |
| `refine.<build>.year_bounds` | `list[integer]` | - | specify min or max & min prediction bounds for samples with XX in year |

#### `subsample.<key>.defaults`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `subsample.<key>.defaults.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `subsample.<key>.defaults.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `subsample.<key>.defaults.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `subsample.<key>.defaults.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `subsample.<key>.defaults.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `subsample.<key>.defaults.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<key>.defaults.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<key>.defaults.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<key>.defaults.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<key>.defaults.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<key>.defaults.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<key>.defaults.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `subsample.<key>.defaults.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `subsample.<key>.defaults.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |

#### `subsample.<key>.samples.<key>`

One of: filterSampleProperties, proximalSampleProperties. Not all properties below apply to every variant.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `subsample.<key>.samples.<key>.context_sample` | `string` | - | Use the outputs from another sample as the inputs for this sample. Value must be a sample name. |
| `subsample.<key>.samples.<key>.drop_sample` | `boolean` | - | Drop this sample from the final output |
| `subsample.<key>.samples.<key>.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `subsample.<key>.samples.<key>.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `subsample.<key>.samples.<key>.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `subsample.<key>.samples.<key>.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `subsample.<key>.samples.<key>.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `subsample.<key>.samples.<key>.focal_sample` | `string` | - | FASTA file with aligned focal sequences to find neighbors for |
| `subsample.<key>.samples.<key>.group_by` | `object` | - | Grouping columns for subsampling. Notes:  (1) Grouping by ['month', 'week', 'year'] is only     supported when there is a 'date' column in the     metadata. (2) 'week' uses the ISO week numbering system, where a week starts on a     Monday and ends on a Sunday. (3) 'month' and 'week' grouping cannot be used together. (4) Custom columns ['month', 'week', 'year'] in the     metadata are ignored for grouping. Please rename them if you want to     use their values for grouping. |
| `subsample.<key>.samples.<key>.group_by_weights` | `string` | - | TSV file defining weights for grouping. Requirements:  (1) Lines starting with '#' are treated as comment lines. (2) The first non-comment line must be a header row. (3) There must be a numeric ``weight`` column (weights can take on any     non-negative values). (4) Other columns must be a subset of grouping columns, with     combinations of values covering all combinations present in the     metadata. (5) This option only applies when grouping columns and a total sample     size are provided. (6) This option can only be used when probabilistic sampling is allowed.  Notes:  (1) Any grouping columns absent from this file will be given equal     weighting across all values *within* groups defined by the other     weighted columns. (2) An entry with the value ``default`` under all columns will be     treated as the default weight for specific groups present in the     metadata but missing from the weights file. If there is no default     weight and the metadata contains rows that are not covered by the     given weights, augur filter will exit with an error. |
| `subsample.<key>.samples.<key>.ignore_missing_data` | `string` | - | All non-ATGC bases are converted to 'N', and then: - 'none' treats 'N' as a normal base for comparison purposes; - 'all' ignores positions where either sequence is N; - 'flanking' ignores runs of Ns at the start/end of each sequence. |
| `subsample.<key>.samples.<key>.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<key>.samples.<key>.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<key>.samples.<key>.k` | `integer` | - | number of nearest neighbors to find per focal strain |
| `subsample.<key>.samples.<key>.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<key>.samples.<key>.max_distance` | `integer` | - | maximum distance threshold for considering a sequence to match |
| `subsample.<key>.samples.<key>.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<key>.samples.<key>.max_sequences` | `integer` | - | Select no more than this number of sequences (i.e. total sample size). Can be used without grouping columns. |
| `subsample.<key>.samples.<key>.method` | `"hamming"` | - | Proximity approach used |
| `subsample.<key>.samples.<key>.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<key>.samples.<key>.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<key>.samples.<key>.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `subsample.<key>.samples.<key>.probabilistic_sampling` | `boolean` | - | Allow probabilistic sampling during subsampling. This is useful when there are more groups than requested sequences. This option only applies when a total sample size is provided. |
| `subsample.<key>.samples.<key>.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `subsample.<key>.samples.<key>.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |
| `subsample.<key>.samples.<key>.sequences_per_group` | `integer` | - | Select no more than this number of sequences per category. |

### `tip_frequencies`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `tip_frequencies.max_date` | `string \| number` | `6M` | - |
| `tip_frequencies.min_date` | `string \| number` | `2000-01-01` | - |
| `tip_frequencies.narrow_bandwidth` | `number` | `0.2` | - |
| `tip_frequencies.wide_bandwidth` | `number` | `0.6` | - |

### `traits.<key>`

One of: object, object. Not all properties below apply to every variant.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `traits.<key>.columns` | `list[string]` | - | - |
| `traits.<key>.sampling_bias_correction` | `number` | - | - |

