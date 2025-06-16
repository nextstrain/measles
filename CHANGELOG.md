# CHANGELOG

We use this CHANGELOG to document breaking changes, new features, bug fixes,
and config value changes that may affect both the usage of the workflows and
the outputs of the workflows.

Changes for this project _do not_ currently follow the [Semantic Versioning rules](https://semver.org/spec/v2.0.0.html).
Instead, changes appear below grouped by the date they were added to the workflow.

## 2024

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
