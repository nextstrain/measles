# Ingest

This workflow ingests public data from NCBI and outputs curated metadata and
sequences that can be used as input for the phylogenetic workflow.

If you have another data source or private data that needs to be formatted for
the phylogenetic workflow, then you can use a similar workflow to curate your
own data.

## Usage

### With `nextstrain run`

If you haven't set up the measles pathogen, then set it up with:

    nextstrain setup measles

Otherwise, make sure you have the latest set up with:

    nextstrain update measles

Run the ingest workflow with:

    nextstrain run measles ingest <analysis-directory>

Your `<analysis-directory>` will contain the workflow's intermediate files
and two final outputs:

- `results/metadata.tsv`
- `results/sequences.fasta`

### With `nextstrain build`

If you don't have a local copy of the measles repository, use Git to download it

    git clone https://github.com/nextstrain/measles.git

Otherwise, update your local copy of the workflow with:

    cd measles
    git pull --ff-only origin master

Run the ingest workflow with

    cd ingest
    nextstrain build .

The `ingest` directory will contain the workflow's intermediate files
and two final outputs:

- `results/metadata.tsv`
- `results/sequences.fasta`

## Defaults

The defaults directory contains all of the default configurations for the ingest workflow.

[defaults/config.yaml](defaults/config.yaml) contains all of the default configuration parameters
used for the ingest workflow. Use Snakemake's `--configfile`/`--config`
options to override these default values.

## Snakefile and rules

The rules directory contains separate Snakefiles (`*.smk`) as modules of the core ingest workflow.
The modules of the workflow are in separate files to keep the main ingest [Snakefile](Snakefile) succinct and organized.
Modules are all [included](https://snakemake.readthedocs.io/en/stable/snakefiles/modularization.html#includes)
in the main Snakefile in the order that they are expected to run.
