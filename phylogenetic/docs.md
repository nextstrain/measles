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
| `traits` | `object` | (3 entries) | - |

### `additional_inputs[]`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `additional_inputs[].metadata` | `string` | - | - |
| `additional_inputs[].name` | `string` | - | - |
| `additional_inputs[].sequences` | `string` | - | - |

### `align`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `align.reference` | `string` | `measles_reference_{gene}.fasta` | - |

### `ancestral.<build>`

<build>

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `ancestral.<build>.aa_root_sequence` | `string` | - | File(s) of the AA root sequence(s). Differences between this sequence and the inferred root will be reported as mutations on the root branch for each gene. For more than one gene this must include %%GENE like other arguments. |
| `ancestral.<build>.annotation` | `string` | - | GenBank or GFF file containing the annotation. Optional if reconstructing a single gene without nuc data. |
| `ancestral.<build>.genes` | `object` | - | gene(s) to translate (list or file containing list). |
| `ancestral.<build>.infer_ambiguous` | `boolean` | `true` | infer ambiguous states on tip sequences and replace with most likely state |
| `ancestral.<build>.inference` | `"joint" \| "marginal"` | `joint` | calculate joint or marginal maximum likelihood ancestral sequence states |
| `ancestral.<build>.keep_ambiguous` | `boolean` | `false` | do not infer ambiguous states on tip sequences |
| `ancestral.<build>.keep_overhangs` | `boolean` | `false` | do not infer states for gaps (-) on either side of the alignment |
| `ancestral.<build>.output_sequences` | `string` | - | name of FASTA file to save ancestral nucleotide sequences to (FASTA alignments only) |
| `ancestral.<build>.output_translations` | `string` | - | name of the FASTA file(s) to save ancestral amino acid sequences to. Specify the file name via a template like 'ancestral_aa_sequences_%%GENE.fasta' where %%GENE will be replaced bythe gene name. |
| `ancestral.<build>.output_vcf` | `string` | - | name of output VCF file which will include ancestral seqs |
| `ancestral.<build>.report_inconsistent_translation` | `boolean` | `false` | Report where amino acid reconstruction differed from a translation of the reconstructed nuc sequence. Requires nucleotide reconstruction. |
| `ancestral.<build>.root_sequence` | `string` | - | [FASTA alignment only] file of the sequence that is used as root for mutation calling. Differences between this sequence and the inferred root will be reported as mutations on the root branch. If also reconstructing AA sequences, this (nuc) sequence will be translated to form the AA root sequences unless '--aa-root-sequence'/'aa_root_sequence' is provided. |
| `ancestral.<build>.seed` | `integer` | - | seed for random number generation |
| `ancestral.<build>.skip_validation` | `string` | - | Skip validation of input/output files, equivalent to a '--validation-mode'/'validation_mode' value of 'skip'. Use at your own risk! |
| `ancestral.<build>.translations` | `string` | - | Translated alignments for each CDS/Gene. If you are translating multiple genes you must specify the file name via a template like 'aa_sequences_%%GENE.fasta' where %%GENE will be replaced, If you are translating a single gene using a pattern is optional. Currently only supported for FASTA-input. |
| `ancestral.<build>.validation_mode` | `"error" \| "warn" \| "skip"` | `error` | Control if optional validation checks are performed and what happens if they fail.  'error' and 'warn' modes perform validation and emit messages about failed validation checks.  'error' mode causes a non-zero exit status if any validation checks failed, while 'warn' does not.  'skip' mode performs no validation.  Note that some validation checks are non-optional and as such are not affected by this setting.  |
| `ancestral.<build>.vcf_reference` | `string` | - | [VCF alignment only] file of the sequence the VCF was mapped to. Differences between this sequence and the inferred root will be reported as mutations on the root branch. |

### `custom_subsample.<build>`

Custom subsampling configuration. When using --configfile, this is recommended over 'subsample' to ignore default subsampling configuration.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |

#### `custom_subsample.<build>.defaults`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `custom_subsample.<build>.defaults.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `custom_subsample.<build>.defaults.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `custom_subsample.<build>.defaults.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `custom_subsample.<build>.defaults.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `custom_subsample.<build>.defaults.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `custom_subsample.<build>.defaults.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<build>.defaults.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<build>.defaults.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<build>.defaults.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<build>.defaults.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<build>.defaults.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<build>.defaults.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `custom_subsample.<build>.defaults.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `custom_subsample.<build>.defaults.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |

#### `custom_subsample.<build>.samples.<key>`

One of: filterSampleProperties, proximalSampleProperties. Not all properties below apply to every variant.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `custom_subsample.<build>.samples.<key>.context_sample` | `string` | - | Use the outputs from another sample as the inputs for this sample. Value must be a sample name. |
| `custom_subsample.<build>.samples.<key>.drop_sample` | `boolean` | - | Drop this sample from the final output |
| `custom_subsample.<build>.samples.<key>.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `custom_subsample.<build>.samples.<key>.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `custom_subsample.<build>.samples.<key>.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `custom_subsample.<build>.samples.<key>.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `custom_subsample.<build>.samples.<key>.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `custom_subsample.<build>.samples.<key>.focal_sample` | `string` | - | FASTA file with aligned focal sequences to find neighbors for |
| `custom_subsample.<build>.samples.<key>.group_by` | `object` | - | Grouping columns for subsampling. Notes:  (1) Grouping by ['month', 'week', 'year'] is only     supported when there is a 'date' column in the     metadata. (2) 'week' uses the ISO week numbering system, where a week starts on a     Monday and ends on a Sunday. (3) 'month' and 'week' grouping cannot be used together. (4) Custom columns ['month', 'week', 'year'] in the     metadata are ignored for grouping. Please rename them if you want to     use their values for grouping. |
| `custom_subsample.<build>.samples.<key>.group_by_weights` | `string` | - | TSV file defining weights for grouping. Requirements:  (1) Lines starting with '#' are treated as comment lines. (2) The first non-comment line must be a header row. (3) There must be a numeric ``weight`` column (weights can take on any     non-negative values). (4) Other columns must be a subset of grouping columns, with     combinations of values covering all combinations present in the     metadata. (5) This option only applies when grouping columns and a total sample     size are provided. (6) This option can only be used when probabilistic sampling is allowed.  Notes:  (1) Any grouping columns absent from this file will be given equal     weighting across all values *within* groups defined by the other     weighted columns. (2) An entry with the value ``default`` under all columns will be     treated as the default weight for specific groups present in the     metadata but missing from the weights file. If there is no default     weight and the metadata contains rows that are not covered by the     given weights, augur filter will exit with an error. |
| `custom_subsample.<build>.samples.<key>.ignore_missing_data` | `string` | - | All non-ATGC bases are converted to 'N', and then: - 'none' treats 'N' as a normal base for comparison purposes; - 'all' ignores positions where either sequence is N; - 'flanking' ignores runs of Ns at the start/end of each sequence. |
| `custom_subsample.<build>.samples.<key>.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<build>.samples.<key>.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `custom_subsample.<build>.samples.<key>.k` | `integer` | - | number of nearest neighbors to find per focal strain |
| `custom_subsample.<build>.samples.<key>.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<build>.samples.<key>.max_distance` | `integer` | - | maximum distance threshold for considering a sequence to match |
| `custom_subsample.<build>.samples.<key>.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<build>.samples.<key>.max_sequences` | `integer` | - | Select no more than this number of sequences (i.e. total sample size). Can be used without grouping columns. |
| `custom_subsample.<build>.samples.<key>.method` | `"hamming"` | - | Proximity approach used |
| `custom_subsample.<build>.samples.<key>.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `custom_subsample.<build>.samples.<key>.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `custom_subsample.<build>.samples.<key>.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `custom_subsample.<build>.samples.<key>.probabilistic_sampling` | `boolean` | - | Allow probabilistic sampling during subsampling. This is useful when there are more groups than requested sequences. This option only applies when a total sample size is provided. |
| `custom_subsample.<build>.samples.<key>.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `custom_subsample.<build>.samples.<key>.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |
| `custom_subsample.<build>.samples.<key>.sequences_per_group` | `integer` | - | Select no more than this number of sequences per category. |

### `export.<build>`

<build>

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `export.<build>.auspice_config` | `object` | `[]` | Auspice configuration file(s) |
| `export.<build>.build_url` | `string` | - | Build URL/repository to be displayed by Auspice |
| `export.<build>.color_by_metadata` | `object` | - | Metadata columns to include as coloring options. Ignores columns named 'none', so please rename them if you would like to include them as colorings. |
| `export.<build>.description` | `string` | - | Markdown file with description of build and/or acknowledgements to be displayed by Auspice |
| `export.<build>.geo_resolutions` | `object` | - | Geographic traits to be displayed on map |
| `export.<build>.include_root_sequence` | `boolean` | `false` | Export as an additional JSON. The filename will follow the pattern of <OUTPUT>_root-sequence.json for a main auspice JSON of <OUTPUT>.json |
| `export.<build>.include_root_sequence_inline` | `boolean` | `false` | Export the root sequence within the dataset JSON. This should only be used for small genomes for file size reasons. |
| `export.<build>.lat_longs` | `string` | - | Latitudes and longitudes for geography traits. See this file for the format: <https://github.com/nextstrain/augur/blob/34.1.4/augur/data/lat_longs.tsv>. This file provides the default set of latitudes and longitudes. An additional file specified by this option will extend the default set. Duplicates based on the first two columns will be resolved by taking the coordinates from the user-provided file. |
| `export.<build>.maintainers` | `object` | - | Analysis maintained by, in format 'Name <URL>' 'Name2 <URL>', ... |
| `export.<build>.metadata_columns` | `object` | - | Metadata columns to export in addition to columns provided by --color-by-metadata or colorings in the Auspice configuration file. These columns will not be used as coloring options in Auspice but will be visible in the tree. Ignores columns named 'none', so please rename them if you would like to include them as metadata fields. |
| `export.<build>.metadata_delimiters` | `object` | `[",", "\t"]` | delimiters to accept when reading a metadata file. Only one delimiter will be inferred. |
| `export.<build>.minify_json` | `boolean` | `false` | Always export JSONs without indentation or line returns. A truthy value (e.g. 1) in :envvar:`AUGUR_MINIFY_JSON` has the same effect, but it can be overridden by ``--no-minify-json``. |
| `export.<build>.no_minify_json` | `boolean` | `false` | Always export JSONs to be human readable. This overrides :envvar:`AUGUR_MINIFY_JSON`. |
| `export.<build>.node_data` | `object` | - | JSON files containing metadata for nodes in the tree. Keys are automatically exported as colorings unless special-cased. URLs for a key 'X' can be stored under key 'X__url' and will be automatically exported. |
| `export.<build>.output_auspice_config` | `string` | - | Write out the merged auspice configuration file for debugging purposes etc. File is only written if you provide multiple config files via --auspice-config. |
| `export.<build>.panels` | `object` | - | Restrict panel display in auspice. Options are tree, map, entropy, frequencies, measurements. Ignore this option to display all available panels. |
| `export.<build>.skip_validation` | `string` | - | Skip validation of input/output files, equivalent to a '--validation-mode'/'validation_mode' value of 'skip'. Use at your own risk! |
| `export.<build>.title` | `string` | - | Title to be displayed by auspice |
| `export.<build>.validation_mode` | `"error" \| "warn" \| "skip"` | `error` | Control if optional validation checks are performed and what happens if they fail.  'error' and 'warn' modes perform validation and emit messages about failed validation checks.  'error' mode causes a non-zero exit status if any validation checks failed, while 'warn' does not.  'skip' mode performs no validation.  Note that some validation checks are non-optional and as such are not affected by this setting.  |
| `export.<build>.warning` | `string` | - | Text or file in Markdown format to be displayed as a warning banner by Auspice |

### `inputs[]`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `inputs[].metadata` | `string` | - | - |
| `inputs[].name` | `string` | - | - |
| `inputs[].sequences` | `string` | - | - |

### `refine.<build>`

Refine configuration.

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
| `refine.<build>.root` | `object` | `["best"]` | rooting mechanism ('best', 'least-squares', 'min_dev', 'oldest', 'mid_point') OR node to root by OR two nodes indicating a monophyletic group to root by. Run treetime -h for definitions of rooting methods. |
| `refine.<build>.seed` | `integer` | - | seed for random number generation |
| `refine.<build>.seq_type` | `"nuc" \| "aa"` | `nuc` | Sequence type: 'nuc' or 'aa' |
| `refine.<build>.stochastic_resolve` | `boolean` | `false` | Resolve polytomies via stochastic subtree building rather than greedy optimization |
| `refine.<build>.timetree` | `boolean` | `false` | produce timetree using treetime, requires tree where branch length is in units of average number of nucleotide or protein substitutions per site (and branch lengths do not exceed 4) |
| `refine.<build>.use_fft` | `boolean` | `false` | produce timetree using FFT for convolutions |
| `refine.<build>.vcf_reference` | `string` | - | fasta file of the sequence the VCF was mapped to |
| `refine.<build>.verbosity` | `integer` | `1` | treetime verbosity, between 0 and 6 (higher values more output) |
| `refine.<build>.year_bounds` | `object` | - | specify min or max & min prediction bounds for samples with XX in year |

### `subsample.<build>`

Subsampling configuration. When using --configfile, it is recommended to use 'custom_subsample' instead to ignore default subsampling configuration.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |

#### `subsample.<build>.defaults`

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `subsample.<build>.defaults.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `subsample.<build>.defaults.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `subsample.<build>.defaults.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `subsample.<build>.defaults.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `subsample.<build>.defaults.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `subsample.<build>.defaults.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<build>.defaults.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<build>.defaults.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<build>.defaults.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<build>.defaults.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<build>.defaults.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<build>.defaults.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `subsample.<build>.defaults.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `subsample.<build>.defaults.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |

#### `subsample.<build>.samples.<key>`

One of: filterSampleProperties, proximalSampleProperties. Not all properties below apply to every variant.

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `subsample.<build>.samples.<key>.context_sample` | `string` | - | Use the outputs from another sample as the inputs for this sample. Value must be a sample name. |
| `subsample.<build>.samples.<key>.drop_sample` | `boolean` | - | Drop this sample from the final output |
| `subsample.<build>.samples.<key>.exclude` | `object` | - | File(s) with list of strains to exclude. |
| `subsample.<build>.samples.<key>.exclude_all` | `boolean` | - | Exclude all strains by default. Use this with the include arguments to select a specific subset of strains. |
| `subsample.<build>.samples.<key>.exclude_ambiguous_dates_by` | `"any" \| "day" \| "month" \| "year"` | - | Exclude ambiguous dates by day (e.g., 2020-09-XX), month (e.g., 2020-XX-XX), year (e.g., 200X-10-01), or any date fields. An ambiguous year makes the corresponding month and day ambiguous, too, even if those fields have unambiguous values (e.g., "201X-10-01"). Similarly, an ambiguous month makes the corresponding day ambiguous (e.g., "2010-XX-01"). |
| `subsample.<build>.samples.<key>.exclude_invalid` | `boolean` | - | Exclude sequences that contain invalid characters. |
| `subsample.<build>.samples.<key>.exclude_where` | `object` | - | Exclude sequences matching these conditions. Ex: "host=rat" or "host!=rat". Multiple values are processed as OR (matching any of those specified will be excluded), not AND. |
| `subsample.<build>.samples.<key>.focal_sample` | `string` | - | FASTA file with aligned focal sequences to find neighbors for |
| `subsample.<build>.samples.<key>.group_by` | `object` | - | Grouping columns for subsampling. Notes:  (1) Grouping by ['month', 'week', 'year'] is only     supported when there is a 'date' column in the     metadata. (2) 'week' uses the ISO week numbering system, where a week starts on a     Monday and ends on a Sunday. (3) 'month' and 'week' grouping cannot be used together. (4) Custom columns ['month', 'week', 'year'] in the     metadata are ignored for grouping. Please rename them if you want to     use their values for grouping. |
| `subsample.<build>.samples.<key>.group_by_weights` | `string` | - | TSV file defining weights for grouping. Requirements:  (1) Lines starting with '#' are treated as comment lines. (2) The first non-comment line must be a header row. (3) There must be a numeric ``weight`` column (weights can take on any     non-negative values). (4) Other columns must be a subset of grouping columns, with     combinations of values covering all combinations present in the     metadata. (5) This option only applies when grouping columns and a total sample     size are provided. (6) This option can only be used when probabilistic sampling is allowed.  Notes:  (1) Any grouping columns absent from this file will be given equal     weighting across all values *within* groups defined by the other     weighted columns. (2) An entry with the value ``default`` under all columns will be     treated as the default weight for specific groups present in the     metadata but missing from the weights file. If there is no default     weight and the metadata contains rows that are not covered by the     given weights, augur filter will exit with an error. |
| `subsample.<build>.samples.<key>.ignore_missing_data` | `string` | - | All non-ATGC bases are converted to 'N', and then: - 'none' treats 'N' as a normal base for comparison purposes; - 'all' ignores positions where either sequence is N; - 'flanking' ignores runs of Ns at the start/end of each sequence. |
| `subsample.<build>.samples.<key>.include` | `object` | - | File(s) with list of strains to include regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<build>.samples.<key>.include_where` | `object` | - | Include sequences with these values. ex: host=rat. Multiple values are processed as OR (having any of those specified will be included), not AND. This rule is applied last and ensures any strains matching these rules will be included regardless of priorities, subsampling, or absence of an entry in sequences. |
| `subsample.<build>.samples.<key>.k` | `integer` | - | number of nearest neighbors to find per focal strain |
| `subsample.<build>.samples.<key>.max_date` | `string \| integer` | - | Maximal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<build>.samples.<key>.max_distance` | `integer` | - | maximum distance threshold for considering a sequence to match |
| `subsample.<build>.samples.<key>.max_length` | `integer` | - | Maximum length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<build>.samples.<key>.max_sequences` | `integer` | - | Select no more than this number of sequences (i.e. total sample size). Can be used without grouping columns. |
| `subsample.<build>.samples.<key>.method` | `"hamming"` | - | Proximity approach used |
| `subsample.<build>.samples.<key>.min_date` | `string \| integer` | - | Minimal cutoff for date (inclusive). Supported formats:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `subsample.<build>.samples.<key>.min_length` | `integer` | - | Minimal length of the sequences, only counting valid characters (excluding gaps, ambiguous, and invalid characters). |
| `subsample.<build>.samples.<key>.non_nucleotide` | `boolean` | - | Deprecated, please use 'exclude_invalid' instead. Exclude sequences that contain invalid characters. |
| `subsample.<build>.samples.<key>.probabilistic_sampling` | `boolean` | - | Allow probabilistic sampling during subsampling. This is useful when there are more groups than requested sequences. This option only applies when a total sample size is provided. |
| `subsample.<build>.samples.<key>.query` | `string` | - | Filter sequences by attribute. Uses `Pandas DataFrame query syntax`__. (e.g., "country == 'Colombia'" or "(country == 'USA' & (division == 'Washington'))")  __ https://pandas.pydata.org/pandas-docs/version/2.3/user_guide/indexing.html#indexing-query |
| `subsample.<build>.samples.<key>.query_columns` | `object` | - | Use alongside query to specify columns and data types in the format 'column:type', where type is one of (bool,float,int,str). Automatic type inference will be attempted on all unspecified columns used in the query. Example: region:str coverage:float. |
| `subsample.<build>.samples.<key>.sequences_per_group` | `integer` | - | Select no more than this number of sequences per category. |

### `tip_frequencies.<build>`

<build>

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `tip_frequencies.<build>.alignments` | `object` | - | alignments to estimate mutations frequencies for |
| `tip_frequencies.<build>.censored` | `boolean` | `false` | calculate censored frequencies at each pivot |
| `tip_frequencies.<build>.gene_names` | `object` | - | names of the sequences in the alignment, same order assumed |
| `tip_frequencies.<build>.ignore_char` | `string` | `` | character to be ignored in frequency calculations |
| `tip_frequencies.<build>.include_internal_nodes` | `boolean` | `false` | calculate frequencies for internal nodes as well as tips |
| `tip_frequencies.<build>.inertia` | `number` | `0.0` | determines how frequencies continue in absense of data (inertia=0 -> go flat, inertia=1.0 -> continue current trend) |
| `tip_frequencies.<build>.max_date` | `string \| number` | - | date to end frequencies calculations; may be specified as:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `tip_frequencies.<build>.metadata_delimiters` | `object` | `[",", "\t"]` | delimiters to accept when reading a metadata file. Only one delimiter will be inferred. |
| `tip_frequencies.<build>.method` | `"diffusion" \| "kde"` | - | method by which frequencies should be estimated |
| `tip_frequencies.<build>.min_date` | `string \| number` | - | date to begin frequencies calculations; may be specified as:  1. an Augur-style numeric date with the year as the integer part (e.g.    2020.42) or 2. a date in ISO 8601 date format (i.e. YYYY-MM-DD) (e.g. '2020-06-04') or 3. a backwards-looking relative date in ISO 8601 duration format with    optional P prefix (e.g. '1W', 'P1W') |
| `tip_frequencies.<build>.minimal_clade_size` | `integer` | `0` | minimal number of tips a clade must have for its diffusion frequencies to be reported |
| `tip_frequencies.<build>.minimal_clade_size_to_estimate` | `integer` | `10` | minimal number of tips a clade must have for its diffusion frequencies to be estimated by the diffusion likelihood; all smaller clades will inherit frequencies from their parents |
| `tip_frequencies.<build>.minimal_frequency` | `number` | `0.05` | minimal all-time frequencies for a trajectory to be estimates |
| `tip_frequencies.<build>.narrow_bandwidth` | `number` | `0.08333333333333333` | the bandwidth for the narrow KDE |
| `tip_frequencies.<build>.output_format` | `"auspice" \| "nextflu"` | `auspice` | format to export frequencies JSON depending on the viewing interface |
| `tip_frequencies.<build>.pivot_interval` | `integer` | `3` | number of units between pivots |
| `tip_frequencies.<build>.pivot_interval_units` | `"months" \| "weeks"` | `months` | space pivots by months (default) or by weeks |
| `tip_frequencies.<build>.proportion_wide` | `number` | `0.2` | the proportion of the wide bandwidth to use in the KDE mixture model |
| `tip_frequencies.<build>.regions` | `object` | `["global"]` | region to filter to. Regions should match values in the 'region' column of the metadata file if specifying values other than the default 'global' region. |
| `tip_frequencies.<build>.stiffness` | `number` | `10.0` | parameter penalizing curvature of the frequency trajectory |
| `tip_frequencies.<build>.weights` | `string` | - | a dictionary of key/value mappings in JSON format used to weight KDE tip frequencies |
| `tip_frequencies.<build>.weights_attribute` | `string` | - | name of the attribute on each tip whose values map to the given weights dictionary |
| `tip_frequencies.<build>.wide_bandwidth` | `number` | `0.25` | the bandwidth for the wide KDE |

### `translate.<build>`

<build>

| Parameter Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `translate.<build>.alignment_output` | `string` | - | write out translated gene alignments. If a VCF-input, a .vcf or .vcf.gz will be output here (depending on file ending). If fasta-input, specify the file name like so: 'my_alignment_%%GENE.fasta', where '%%GENE' will be replaced by the name of the gene |
| `translate.<build>.genes` | `object` | - | genes to translate (list or file containing list) |
| `translate.<build>.output_node_data` | `string` | - | name of JSON file to save aa-mutations to |
| `translate.<build>.reference_sequence` | `string` | - | GenBank or GFF file containing the annotation |
| `translate.<build>.skip_validation` | `string` | - | Skip validation of input/output files, equivalent to a '--validation-mode'/'validation_mode' value of 'skip'. Use at your own risk! |
| `translate.<build>.validation_mode` | `"error" \| "warn" \| "skip"` | `error` | Control if optional validation checks are performed and what happens if they fail.  'error' and 'warn' modes perform validation and emit messages about failed validation checks.  'error' mode causes a non-zero exit status if any validation checks failed, while 'warn' does not.  'skip' mode performs no validation.  Note that some validation checks are non-optional and as such are not affected by this setting.  |
| `translate.<build>.vcf_reference` | `string` | - | fasta file of the sequence the VCF was mapped to |
| `translate.<build>.vcf_reference_output` | `string` | - | fasta file where reference sequence translations for VCF input will be written |

