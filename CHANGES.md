# CHANGELOG
* 2 April 2024: Add nextstrain-automation build-configs for deploying the final Auspice dataset of the phylogenetic workflow
* 1 April 2024: Create a tree using the 450 nucleotides encoding the carboxyl-terminal 150 amino acids of the nucleoprotein (N450), which is highly represented on NCBI for measles. [PR #20](https://github.com/nextstrain/measles/pull/20)
* 15 March 2024: Connect ingest and phylogenetic workflows to follow the pathogen-repo-guide by uploading ingest output to S3, downloading ingest output from S3 to phylogenetic directory, using "accession" column as the ID column, and using a color scheme that matches the new region name format. [PR #19](https://github.com/nextstrain/measles/pull/19)
* 1 March 2024: Add phylogenetic directory to follow the pathogen-repo-guide, and update the CI workflow to match the new file structure. [PR #18](https://github.com/nextstrain/measles/pull/18)
* 14 February 2024: Add ingest directory from pathogen-repo-guide and make measles-specific modifications. [PR #10](https://github.com/nextstrain/measles/pull/10)
* 11 January 2024: Use a config file to define hardcoded parameters and file paths, and add a change log. [PR #9](https://github.com/nextstrain/measles/pull/9)
