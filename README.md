# Nextstrain repository for measles virus

This repository contains three workflows for the analysis of measles virus data:

- [`ingest/`](./ingest) - Download data from GenBank, clean and curate it
- [`phylogenetic/`](./phylogenetic) - Filter sequences, align, construct phylogeny and export for visualization
- [`nextclade/`](./nextclade) - Create nextclade datasets

Each folder contains a README.md with more information. The results of running both workflows are publicly visible at [nextstrain.org/measles](https://nextstrain.org/measles).

## Installation

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html) for Nextstrain's suite of software tools.

## Quickstart

Run the default phylogenetic workflow via:
```
cd phylogenetic/
nextstrain build .
nextstrain view .
```

## Documentation

- [Running a pathogen workflow](https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html)
