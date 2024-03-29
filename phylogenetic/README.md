# nextstrain.org/measles

This is the [Nextstrain](https://nextstrain.org) build for measles, visible at
[nextstrain.org/measles](https://nextstrain.org/measles).

## Software requirements

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html)
for Nextstrain's suite of software tools.

## Usage

If you're unfamiliar with Nextstrain builds, you may want to follow our
[Running a Pathogen Workflow guide](https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html) first and then come back here.

The easiest way to run this pathogen build is using the Nextstrain
command-line tool from within the `phylogenetic/` directory:

    cd phylogenetic/
    nextstrain build .

Build output goes into the directories `data/`, `results/` and `auspice/`.

Once you've run the build, you can view the results with:

    nextstrain view .

## Configuration

Configuration takes place entirely with the `Snakefile`. This can be read
top-to-bottom, each rule specifies its file inputs and output and also its
parameters. There is little redirection and each rule should be able to be
reasoned with on its own.

### Using GenBank data

This build starts by pulling preprocessed sequence and metadata files from:

* https://data.nextstrain.org/files/measles/sequences.fasta.zst
* https://data.nextstrain.org/files/measles/metadata.tsv.zst

The above datasets have been preprocessed and cleaned from GenBank.

### Using example data

Alternatively, you can run the build using the
example data provided in this repository.  To run the build by copying the
example sequences into the `data/` directory, use the following:

    nextstrain build .  --configfile profiles/ci/profiles_config.yaml
