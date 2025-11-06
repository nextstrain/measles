# Measles Virus (MeV) Washington-Focused Build

## Build Overview
- **Build Name**: Measles Virus Washington-Focused Build
- **Pathogen/Strain**: Measles virus (MeV)
- **Scope**: Full-genome sequences representing all strains (A-H)
- **Purpose**: This repository contains the Nextstrain build for Measles virus (MeV). Sequences are included from Washington State, with contextual sequences of North America and global origin included using a tiered-subsampling scheme. Full-genomes are curated for the purposes of inferring strain, assessing patterns of epidemiological linkage, and exploring sources of introduction. N450 sequence dataset is curated similarly, but for inclusion of a larger dataset that provides stronger evidence for strain identity.

- **Nextstrain Build/s Location/s**:  [https://nextstrain.org/groups/wadoh/measles/wa/genome/](https://nextstrain.org/groups/wadoh/measles/wa/genome/)

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
  - Two genotypes are currently circulating - B3 and D8. 'A' genotypes are vaccine strains.
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
    - Identification of genotypes outside of clade A can rule out vaccination-related infections.
    - Full genomes can assist in monitoring the effectiveness of established PCR-based diagnostic assays.
    - Vaccine escape has not been observed, but should be monitored.

- Additional Resources
  - [Global Measles and Rubell Laboratory Netowrk](https://www.who.int/europe/initiatives/measles-and-rubella-laboratory-network) 
  - [Most Recent WHO Measles Nomenclature Update - 2012](https://www.who.int/publications/i/item/WER8709)

## Scientific Decisions

Nextstrain builds are designed for specific purposes and not all types of builds for a particular pathogen will answer the same questions. The following are critical decisions that were made during the development of this build that should be kept in mind when analyzing the data and using this build.

- **Nomenclature**: The nomenclature used in this build to designate clade names is determined by the Global Measles and Rubella Laboratory Network.
- **Subsampling**: This build incorporates all known sequences from Washington State, XX additional sequences from North America and XX additional samples of global origin.
- **Root selection**: The root sequence is not specified, but inferred by `augur ancestral`.
- **Reference selection**: Ichinose B95a strain (Genbank accession #NC_001498) was the reference for full genome and N450 alignments.
- **Inclusion/Exclusion**: Strains isolated from subacute sclerosing panencephalitis (SSPE) cases are excluded, as they contain hypermutations that prevent strain designation, and do not shed typically, making them very atypical strains overall. Vaccine reference strains (A- genotypes) are force-included following all other subsampling procedures.

### Data Sources & Inputs
This build relies on publicly available data sourced from [data sources].

- **Sequence Data**: All sequence data originate from [NCBI](https://www.ncbi.nlm.nih.gov/).
- **Metadata**: All metadata originate from [NCBI](https://www.ncbi.nlm.nih.gov/).
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
git clone https://github.com/DOH-DAH0303/measles.git
cd measles/phylogenetic/
```

## Run the Washington-Focused Build

Make sure you are located in the build folder `phylogenetic` before running the build command:

```
nextstrain build . --configfile build-configs/state_focused/config.yaml
```

When you run the build using the above command, Nextstrain uses Snakemake as the workflow manager to automate genomic analyses. The Snakefile in a Nextstrain build defines how raw input data (sequences and metadata) are processed step-by-step in an automated way. Nextstrain builds are powered by Augur (for phylogenetics) and Auspice (for visualization) and Snakemake is used to automate the execution of these steps using Augur and Auspice based on file dependencies.

Alternative configuration files can be specified to customize the workflow. In this case, `--configfile build-configs/state_focused/config.yaml` tweaks the workflow such that samples are pulled preferentially from Washington state, then North America, then globally, with numbers of samples from each layer specified in the `config.yaml`.

## Run the Build with Test Data (Optional)
An alternative configuration file is present for running the phylogenetic workflow on a smaller example data set. In this case, `--configfile build-configs/ci/config.yaml` tweaks the workflow such this dataset located in `phylogenetic/example_data` gets copied to `phylogenetic/data`, and bypasses the default steps of downloading and decompressing the full dataset provided by Nextstrain.

```
nextstrain build . --configfile build-configs/ci/config.yaml
```

## Modify the Build to Use Data Straight from NCBI
When running this build, data are downloaded from the Nextstrain measles data repository. This repository is updated at regular intervals; however, if you wish to pull the latest data directly from NCBI, you can run your own ingest workflow.

First, comment out the custom rules section of the build-configs/state_focused/config.yaml. The top of the file looks like this:
```
### Uncomment the custom rules section below to:
### - pull preferentially from the ingest results.
### See README.md for more information

#custom_rules:
#    - build-configs/state_focused/copy_from_ingest.smk
builds: 'genome'
custom_subsample:
    genome:
        defaults:
            exclude_ambiguous_dates_by: year  
        samples:
```

You can run the ingest workflow first by running `nextstrain build .` from the `ingest` directory. After these edit to the `config.yaml`, the state-focused build will now always check for data in the `ingest/results` directory, and build preferentially from those. When they are not present, the build pulls data from Nextstrain. If you want to make sure you are always pulling the most recent data from NCBI, navigate to the main `measles/` directory and run the following:

```
nextstrain build ingest --forceall &&
nextstrain build phylogenetic --configfile build-configs/state_focused/config.yaml
```

### Expected Outputs
The file structure of the `phylogenetic/` directory is as follows with `*`" folders denoting folders that are the build's expected outputs.

```
.
├── README.md
├── Snakefile
├── auspice*
├── build-configs
├── data
├── defaults
├── example_data
├── results*
└── rules
```
More details on the file structure of this build can be found [here](https://github.com/NW-PaGe/measles/wiki)

After successfully running the build there will be two output folders containing the build results.

- `auspice/` folder contains `measles_genome.json`. This is the final result viewable by auspice.
- `results/` folder contains the `genome` folder containing intermediate outputs from the respective workflows.

### Visualize Results
- Option 1: Open [auspice.us](auspice.us) in a web browser, and drop in `measles_genome.json` as input. 
- Option 2: Run `nextstrain view .` from your `measles/phylogenetic/` folder.

- To learn more about how to make epidemiologic inferences from phylogenetic trees, see [The Applied Genomic Epidemiology Handbook](https://www.czbiohub.org/ebook/applied-genomic-epidemiology-handbook/welcome-to-the-applied-genomic-epidemiology-handbook/).


## Customization for Local Adaptation

This build can be customized for use by other states. This is configurable by editing a single file, `measles/phylogenetic/build-configs/state_focused/config.yaml`. To change the focal state, change the `division` on line 4 of the config file. Simply replace "Washington" with your state of interest.

## Contributing
For any questions please submit them to our [Discussions](https://github.com/orgs/NW-PaGe/discussions) page. Software issues and requests can be logged as a Git [Issue](https://github.com/NW-PaGe/measles/issues).

## License
This project is licensed under a modified GPL-3.0 License.
You may use, modify, and distribute this work, but commercial use is strictly prohibited without prior written permission.

## Acknowledgements

We gratefully acknowledge the contributions of the AMD teams (Microbiology, MEP, Bioinformatics, DIQA), Washington State Public Health Laboratories (WA PHL), and our colleagues at the Washington State Department of Health, whose expertise and dedication made this work possible. We also extend our sincere thanks to the Nextstrain development team for their ongoing collaboration and support.

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
