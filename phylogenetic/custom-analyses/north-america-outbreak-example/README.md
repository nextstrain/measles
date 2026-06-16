# Measles North America outbreak example custom workflow

This workflow configuration is intended to be run as a stand-alone analysis directory via `nextstrain run`, in conjunction with our canonical measles phylogenetic workflow.

## Running via `nextstrain run`

1. (Prerequisite) `nextstrain` installed with a working runtime. Minimum version: X.Y.Z (TODO XXX)
1. Install the measles repo via `nextstrain setup measles` TODO XXX check minimum version, or just say "update"?
1. cd into an empty analysis directory
1. Somehow (TODO XXX) obtain the `config.yaml` and `auspice_config.json` and place them in the current directory (the analysis directory)
1. `nextstrain run measles phylogenetic .`


## Development

You can run this in the context of the measles repo by treating this directory (`phylogenetic/custom-analyses/outbreak-example/`) as an isolated analysis directory which just so happens to be inside the measles repo.

Our Snakemake code, specifically `config.smk`, will automatically pull in `./config.yaml` ( (a sister file to this readme) and use it as a config overlay on top of the workflow's default `phylogenetic/defaults/config.yaml`.
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
