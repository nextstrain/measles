# Measles Virus (MeV) Washington-Focused Build

## Build Overview
- **Build Name**: Measles Virus Washington-Focused Build
- **Pathogen/Strain**: Measles Virus (MeV)
- **Scope**: Full-genome sequences, and N450 (a 450 bp terminal N-protein region) sequences.
- **Purpose**: This repository contains the Nextstrain build for Measles virus. Sequences are included from Washington State, with contextual sequences of North America and global origin included using a tiered-subsampling scheme. Full-genome are curated for the purposes of inferring strain, epidemiological case linkage, and sources of introduction. N450 sequence dataset is curated similarly, but for inclusion of a larger dataset that provides stronger evidence for strain identity.

- **Nextstrain Build/s Location/s**:  URL TBD

## Table of Contents
- [Pathogen Epidemiology](#pathogen-epidemiology)
- [Scientific Decisions](#scientific-decisions)
- [Getting Started](#getting-started)
  - [Data Sources & Inputs](#data-sources--inputs)
  - [Setup & Dependencies](#setup--dependencies)
    - [Installation](#installation)
    - [Clone the repository](#clone-the-repository)
- [Run the Build](#run-the-build-with-test-data)
  - [Expected Outputs](#expected-outputs)
  - [Visualizing Results](#visualize-results)
- [Customization for Local Adaptation](#customization-for-local-adaptation)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)


## Pathogen Epidemiology
- Overview:
  - MeV is an RNA virus in the family Paramyxoviridae
  - Two genotypes are currently circulating - B3 and D8. A genotypes are vaccine strains.
  - Transmission occurs through contact - either directly or through aerosolized nasal and through secretions.
- Taxonomic designations include clades (A-H) and subclades (numbered).
- Geographic Distribution and Seasonality
  - MeV is distributed globally, with the highest case numbers in areas with low vaccination coverage. Children of school age are at higher risk.
  - In temperate regions, higher transmission can occur in based on patterns in schooling, while agricultural patterns can drive transmission in less developed areas.

- Public health importance
  - Surveillance for MeV can help identify high-risk populations.
- Genomic Relevance
  - Why are genomic data useful for this pathogen:
    - Full-genome data allows for outbreak investigation and identification of case clusters.
    - Most genotypes have been declared inactive. Genomic surveillance can help detect emergence of novel genotypes.
    - A few sporadic lineage A cases have been observed in recently vaccinated. Placement outside of clade A can rule out vaccination-related infections.
    - Full genomes can assist in monitoring the effectiveness of established PCR-based diagnostic assays.
    - Vaccine escape has not been observed, but should me monitored.
  - Why N450 data are useful for this pathogen:
    - The N450 sequence results from the standard diagnostic assay, and may be obtained as part of routine surveillance in jurisdictions with low resources.
    - The N450 dataset is very large, and useful for genotype identification. These data can help to identify emerging genotypes, and also genotypes that have been declared inactive.

- Additional Resources
  - [Global Measles and Rubell Laboratory Netowrk](https://www.who.int/europe/initiatives/measles-and-rubella-laboratory-network) 
  - [Most Recent WHO Measles Nomenclature Update - 2012](https://www.who.int/publications/i/item/WER8709)

## Scientific Decisions

Nextstrain builds are designed for specific purposes and not all types of builds for a particular pathogen will answer the same questions. The following are critical decisions that were made during the development of this build that should be kept in mind when analyzing the data and using this build. *Subsampling, root selection, and reference selection must be included at minimum.*

- **Nomenclature**: The nomenclature used in this build to designate clade names is determined by the Global Measles and Rubella Laboratory Network.
- **Subsampling**: This build incorporates all known sequences from Washington State, XX additional sequences from North America and XX additional samples of global origin.
- **Root selection**: The root sequence is not specified, but inferred by `augur ancestral`.
- **Reference selection**: Ichinose B95a strain (Genbank accession #NC_001498) was the reference for full genome and N450 alignments.
- **Inclusion/Exclusion**: Strains isolated from subacute sclerosing panencephalitis (SSPE) cases are excluded, as they contain hypermutations that prevent strain designation, and do not shed typically, making them very atypical isolates overall. Vaccine reference strains (A- genotypes) are force-included following all other subsampling procedures.

## Getting Started
*(Provide any context new users should know before using this project.) Some high-level features and capabilities specific to this build include:*

- [Feature 1: Feature 1 is helpful because it allows for X]
- [Feature 2: Feature 2 is helpful because it allows for X]

### Data Sources & Inputs
*(Provide any information on data sources and the inputs needed to run the build)*
This build relies on publicly available data sourced from [data sources].

- **Sequence Data**: All sequence data originate from [NCBI](https://www.ncbi.nlm.nih.gov/)
- **Metadata**: All metadata originate from [NCBI](https://www.ncbi.nlm.nih.gov/)
- **Expected Inputs**:
    - `measles/phylogenetic/data/sequences.fasta.zst` (containing viral genome sequences)
    - `measles/phylogenetic/data/metadata.tsv.zst` (with relevant sample information)

### Setup & Dependencies
#### Installation
Ensure that you have [Nextstrain](https://docs.nextstrain.org/en/latest/install.html) installed.

To check that Nextstrain is installed:
```
nextstrain check-setup
```

#### Clone the repository:

```
git clone https://github.com/[your-github-repo].git
cd [your-github-repo]
```

## Run the Build
*(Explain how to run the build with test data. Example text on how this might be explained is below)*

To test the pipeline with the provided example data located in `[data_location]/` make sure you are located in the build folder `[your-github-repo]` before running the build command:

```
nextstrain build .
```

When you run the build using `nextstrain build .`, Nextstrain uses Snakemake as the workflow manager to automate genomic analyses. The Snakefile in a Nextstrain build defines how raw input data (sequences and metadata) are processed step-by-step in an automated way. Nextstrain builds are powered by Augur (for phylogenetics) and Auspice (for visualization) and Snakemake is used to automate the execution of these steps using Augur and Auspice based on file dependencies.

### Run the Build with Test Data (Optional)
For builds that do not programmatically pull data from NCBI or another source, include a `test_data/` folder containing a minimal working example of test data that can be successfully executed by the build.

### Expected Outputs
*(Outline the expected outputs and in which folders to locate them)*
The file structure of the repository is as follows with `*`" folders denoting folders that are the build's expected outputs.

```
.
├── README.md
├── Snakefile
├── auspice*
├── clade-labeling
├── config
├── new_data
├── results*
└── scripts
```
More details on the file structure of this build can be found here (link to Wiki page that contains contents of  Repository File Structure Overview section).

After successfully running the build there will be two output folders containing the build results.

- `auspice/` folder contains: a .json file
- `results/` folder contains:

### Visualize Results
- Dropping .json into auspice.us
- `nextstrain view auspice/*.json`

- Link folks to tree interpretation resources that people can use to make their inferences.


## Customization for Local Adaptation
 *[Brief overview on how to adapt this build for another jurisdiction, such as a state, city, county, or country. Including links to Readmes in other sections that contain detailed instructions on what and how to modify the files]*

This build can be customized for use by other demes, including as states, cities, counties, or countries.

- What files or folders need to be modified in order to adapt for other jurisdictions? If this is lengthy then you can link to a wiki page tab that goes into detail on how someone might adapt this build for their jurisdiction.

## Contributing
For any questions please submit them to our [Discussions](insert link here) page otherwise software issues and requests can be logged as a Git [Issue](insert link here).

## License
This project is licensed under a modified GPL-3.0 License.
You may use, modify, and distribute this work, but commercial use is strictly prohibited without prior written permission.

## Acknowledgements

*[add acknowledgements to those who have contributed to this work]*

<!-- Repository File Structure Overview [**Move contents of this section to Wiki**]
(This section outlines the high-level file structure of the repo to help folks navigate the repo. If the build follows the pathogen template repo feel free to make this section brief and link to the pathogen template repo resource)*

Example text below:

This Nextstrain build follows the structure detailed in the [Pathogen Repo Guide](https://github.com/nextstrain/pathogen-repo-guide).
Mainly, this build contains [number] workflows for the analysis of [pathogen] virus data:
- ingest/ [link to ingest workflow] Download data from [source], clean, format, curate it, and assign clades.
- phylogenetic/ [link to phylogenetic workflow] Subsample data and make phylogenetic trees for use in nextstrain.

OR
The file structure of the repository is as follows with `*`" folders denoting folders that are the build's expected outputs.

```
.
├── README.md
├── Snakefile
├── auspice*
├── clade-labeling
├── config
├── new_data
├── results*
└── scripts
```

- `Snakefile`: Snakefile description
- `config/`: contains what
- `new_data/`: contains What
- `scripts/`: contains what
- `clade-labeling`: contains what
-->
