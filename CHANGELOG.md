# CHANGELOG

We use this CHANGELOG to document breaking changes, new features, bug fixes,
and config value changes that may affect both the usage of the workflows and
the outputs of the workflows.

Changes for this project _do not_ currently follow the [Semantic Versioning rules](https://semver.org/spec/v2.0.0.html).
Instead, changes appear below grouped by the date they were added to the workflow.

## 2026
* TBD: Changes to non-subsampling config will no longer trigger a re-run starting from subsampling. [#91][]
* 23 January 2026: Restored support for `nextstrain run`, which was broken when
  adding dynamic colors generation. [#105][]
* 22 January 2026: ingest: fixed the uploaded sequences file extension so the file at
  https://data.nextstrain.org/files/workflows/measles/sequences.fasta.zst is properly updated. [#103][]
* 21 January 2026: ingest: switched `strain` back to the original isolate names. [#98][]
* 15 January 2026: phylogenetic: Split subsampling into `early` and `late` sampling groups [530da56][]
* 14 January 2026: *MAJOR CHANGES* in phylogenetic workflow [1cf1299...0313508][]
    - increased number of sequences to include in genome build
    - added geographic trait reconstruction for genome build. **Requires new config params** `traits.columns` and `traits.sampling_bias_correction`
    - added dynamic colors generation
* 09 January 2026: *MAJOR CHANGES* - Switched to [Pathoplexus][] as the data source for
  the ingest and phylogenetic workflows. **Please consult the [Pathoplexus Data Use Terms][]**
  for details on how the data can be used. [#95][]

[#91]: https://github.com/nextstrain/measles/pull/91
[#95]: https://github.com/nextstrain/measles/pull/95
[#98]: https://github.com/nextstrain/measles/pull/98
[#103]: https://github.com/nextstrain/measles/issues/103
[#105]: https://github.com/nextstrain/measles/pull/105
[530da56]: https://github.com/nextstrain/measles/commit/530da568d8014c08e73f31065a8fa96e5c2d2f20
[1cf1299...0313508]: https://github.com/nextstrain/measles/compare/1cf1299e1658140d9317fc9063f1e06ef04a6ee1...03135085aed310f1cb0d3ecb2dca342e6ec8f51d
[Pathoplexus]: https://pathoplexus.org
[Pathoplexus Data Use Terms]: https://pathoplexus.org/about/terms-of-use/data-use-terms

## 2025
* 22 December 2025: Added workflow for creating the [genome Nextclade dataset][]. [#65][]
* 30 September 2025: The `'gene'` wildcard was renamed as `'build'`, and is now a config key rather than a declaration in the `phylogenetic` snakefile.
* 29 September 2025: Restored support for `nextstrain run`, which was broken in the switch the augur subsample. [#73][]
* 26 September 2025: Updated workflow compatibility declaration in `nextstrain-pathogen.yaml`.
  **This requires Nextstrain CLI >=10.3.0** to setup and update the pathogen without error messages.
  However, workflows will still run with Nextstrain CLI <10.3.0 [#69][]
* 24 September 2025: Implemented augur subsample, replacing augur filter steps for both genome and N450 workflows. **This is a breaking change**. [#70][]
    - Replaces `augur filter` calls with `augur subsample`.
    - Replaces `filter` and `filter_N450` with `subsample` section in the config.yaml.
* 24 September 2025: Configuration resolved at run time is now written to `results/run_config.yaml`. [#70][]
* 22 September 2025: Fixed a bug where `rule align` would fail when the reference sequence was present in the output of `rule filter` [#68][]
* 4 June 2025: Vendored [nextstrain/shared][] to parse config paths across workflows [#62][]
* 21 May 2025: ingest - Replace various scripts with new `augur curate` commands [#61][]
    - Replaces ncov-ingest geolocation rules with built-in `augur curate` geolocation rules
    - Requires a new `curate.genbank_location_field` config param.
    - The config param `curate.geolocation_rules_url` is no longer supported
* 28 March 2025: Added support for `nextstrain run` across all workflows [#55][]
* 20 March 2025: phylogenetic - Add `division` to geo-resolutions and coloring [#59][]

[#55]: https://github.com/nextstrain/measles/pull/55
[#59]: https://github.com/nextstrain/measles/pull/59
[#61]: https://github.com/nextstrain/measles/pull/61
[#62]: https://github.com/nextstrain/measles/pull/62
[#65]: https://github.com/nextstrain/measles/pull/65
[#68]: https://github.com/nextstrain/measles/pull/68
[#69]: https://github.com/nextstrain/measles/pull/69
[#70]: https://github.com/nextstrain/measles/pull/70
[#73]: https://github.com/nextstrain/measles/issues/73
[nextstrain/shared]: https://github.com/nextstrain/shared
[genome Nextclade dataset]: https://clades.nextstrain.org/?dataset-name=nextstrain/measles/genome/WHO-2012

## 2024

* 6 November 2024: phylogenetic - Fix "translate" and "export" rules to use references from config [#53][]
* 19 September 2024: ingest - config `nextclade.field_map` accepts key-value pairs [#52][]
* 3 July 2024: phylogenetic - Add frequencies panel for N450 build [#42][]
* 28 June 2024: phylogenetic - Add default description for builds [#41][]
* 7 June 2024: Assign genotypes using Nextclade dataset and visualize on tree [PR #36](https://github.com/nextstrain/measles/pull/36)
* 9 May 2024: Create a N450 tree that can be used as part of a Nextclade dataset to assign genotypes to measles samples based on criteria outlined by the WHO [PR #28](https://github.com/nextstrain/measles/pull/28)
* 25 April 2024: Add specific sequences and metadata to the measles trees, including WHO reference sequences, vaccine strains, and genotypes reported on NCBI [PR #26](https://github.com/nextstrain/measles/pull/26)
* 10 April 2024: Add a single GH Action workflow to automate the ingest and phylogenetic workflows [PR #22](https://github.com/nextstrain/measles/pull/22)
* 2 April 2024: Add nextstrain-automation build-configs for deploying the final Auspice dataset of the phylogenetic workflow [PR #21](https://github.com/nextstrain/measles/pull/21)
* 1 April 2024: Create a "N450" tree using the 450 nucleotides encoding the carboxyl-terminal 150 amino acids of the nucleoprotein, which is highly represented on NCBI for measles. [PR #20](https://github.com/nextstrain/measles/pull/20)
* 15 March 2024: Connect ingest and phylogenetic workflows to follow the pathogen-repo-guide by uploading ingest output to S3, downloading ingest output from S3 to phylogenetic directory, using "accession" column as the ID column, and using a color scheme that matches the new region name format. [PR #19](https://github.com/nextstrain/measles/pull/19)
* 1 March 2024: Add phylogenetic directory to follow the pathogen-repo-guide, and update the CI workflow to match the new file structure. [PR #18](https://github.com/nextstrain/measles/pull/18)
* 14 February 2024: Add ingest directory from pathogen-repo-guide and make measles-specific modifications. [PR #10](https://github.com/nextstrain/measles/pull/10)
* 11 January 2024: Use a config file to define hardcoded parameters and file paths, and add a change log. [PR #9](https://github.com/nextstrain/measles/pull/9)

[#41]: https://github.com/nextstrain/measles/pull/41
[#42]: https://github.com/nextstrain/measles/pull/42
[#52]: https://github.com/nextstrain/measles/pull/52
[#53]: https://github.com/nextstrain/measles/pull/53
