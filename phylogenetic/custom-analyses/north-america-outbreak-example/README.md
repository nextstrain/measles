# Measles North America outbreak example custom workflow

The files in this directory configure the default measles phylogenetic workflow to use proximal subsampling for the North American outbreak.
The directory with these files is intended as a stand-alone analysis directory.

## How to run

1. [Install](https://docs.nextstrain.org/en/latest/install.html) the latest version of Nextstrain.
1. Install the latest measles pathogen repo via `nextstrain setup measles` or update your existing copy via `nextstrain update measles`
1. Create an empty analysis directory and move into it
1. Create two necessary configuration files in the current directory: `config.yaml` and `auspice_config.json`. The first of these will be automatically picked up when we run the workflow. You can [view these files on GitHub](https://github.com/nextstrain/measles/tree/main/phylogenetic/custom-analyses/north-america-outbreak-example) or fetch them via:
    - `curl --compressed https://raw.githubusercontent.com/nextstrain/measles/refs/heads/main/phylogenetic/custom-analyses/north-america-outbreak-example/config.yaml -o config.yaml`
    - `curl --compressed https://raw.githubusercontent.com/nextstrain/measles/refs/heads/main/phylogenetic/custom-analyses/north-america-outbreak-example/auspice_config.json -o auspice_config.json`
1. Run the customised workflow via `nextstrain run measles phylogenetic .`


## Development

**Run using this directory as an analysis directory**

You can run this in the context of the measles repo by treating this directory (`phylogenetic/custom-analyses/outbreak-example/`) as an isolated analysis directory which just so happens to be inside the measles repo.

Our Snakemake code, specifically `config.smk`, will automatically pull in `./config.yaml` (a sister file to this readme) and use it as a config overlay on top of the workflow's default `phylogenetic/defaults/config.yaml`.
New directories (`.snakemake/`, `results/`, `auspice/` etc) will be created inside this directory as this analysis directory is completely isolated.

There are various methods to run, depending on your preference. Mixing and matching approaches can trigger unnecessary re-runs of rules. Each of these invocations has `-n` (dry-run) which you should remove to actually run:

```sh
cd phylogenetic/custom-analyses/north-america-outbreak-example # i.e. this folder!
snakemake --cores 1 --snakefile ../../Snakefile -pf -n
```

```sh
cd phylogenetic/ # i.e. grandparent of this directory
snakemake --cores 1 --pf -d custom-analyses/north-america-outbreak-example -n
```

```sh
cd phylogenetic/ # i.e. grandparent of this directory
nextstrain build . -- -d custom-analyses/north-america-outbreak-example -n
```
