# nextstrain.org/measles

This is the [Nextstrain](https://nextstrain.org) build for measles, visible at
[nextstrain.org/measles](https://nextstrain.org/measles).

## Software requirements

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html)
for Nextstrain's suite of software tools.

## Usage

If you're unfamiliar with Nextstrain builds, you may want to follow our
[Running a Pathogen Workflow guide](https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html) first and then come back here.

### With `nextstrain run`

If you haven't set up the measles pathogen, then set it up with:

    nextstrain setup measles

Otherwise, make sure you have the latest set up with:

    nextstrain update measles

Run the phylogenetic workflow with:

    nextstrain run measles phylogenetic <analysis-directory>

Your `<analysis-directory>` will contain the workflow's intermediate files
and the final outputs:

- `auspice/measles_genome_tip-frequencies.json`
- `auspice/measles_genome.json`
- `auspice/measles_N450_tip-frequencies.json`
- `auspice/measles_N450.json`

You can view the results with

    nextstrain view <analysis-directory>

### With `nextstrain build`

If you don't have a local copy of the measles repository, use Git to download it

    git clone https://github.com/nextstrain/measles.git

Otherwise, update your local copy of the workflow with:

    cd measles
    git pull --ff-only origin master

Run the phylogenetic workflow workflow with

    cd phylogenetic
    nextstrain build .

The `phylogenetic` directory will contain the workflow's intermediate files
and the final outputs:

- `auspice/measles_genome_tip-frequencies.json`
- `auspice/measles_genome.json`
- `auspice/measles_N450_tip-frequencies.json`
- `auspice/measles_N450.json`

Once you've run the build, you can view the results with:

    nextstrain view .

## Configuration

Configuration for the workflow takes place entirely within the [defaults/config.yaml](defaults/config.yaml).
The analysis pipeline is contained in [Snakefile](Snakefile) with included [rules](rules).
Each rule specifies its file inputs and output and pulls its parameters from the config.
There is little redirection and each rule should be able to be reasoned with on its own.

### Default input data

The default builds start from the public Nextstrain data that have been preprocessed
and cleaned from [Pathoplexus][] that only includes OPEN data.
The default Auspice configs ([genome](./defaults/auspice_config_genome.json),
[N450](./defaults/auspice_config_N450.json)) include the `metadata_columns`
"PPX_accession", "INSDC_accession", and "restrictedUntil" to ensure the builds
adhere to the [Pathoplexus data use terms][].

#### Adding [RESTRICTED data][].

> [!WARNING]
> If you are using [RESTRICTED data][] in your own analysis, please refer to the
> [Pathoplexus Data Use Terms](https://pathoplexus.org/about/terms-of-use/restricted-data).

The Nextstrain automated builds include the [RESTRICTED data][] by adding
them with the `additional_inputs` config parameter.

```yaml
additional_inputs:
  - name: ppx_restricted
    metadata: "s3://nextstrain-data/files/workflows/measles/metadata_restricted.tsv.zst"
    sequences: "s3://nextstrain-data/files/workflows/measles/sequences_restricted.fasta.zst"
```

### Adding your own data

If you want to add your own data to the default input, specify your inputs with
the `additional_inputs` config parameter.

```yaml
additional_inputs:
  - name: private
    metadata: data/metadata.tsv
    sequences: data/sequences.fasta
```

If you want to run the builds _without_ the default data and only use your own
data, you can do so by specifying the `inputs` parameter.

```yaml
inputs:
  - name: private
    metadata: data/metadata.tsv
    sequences: data/sequences.fasta
```

### Using example data

Alternatively, you can run the build using the example data provided in this
repository by running:

    nextstrain build .  --configfile build-configs/ci/config.yaml

Note: this only works with `nextstrain build`. Within repo input files are _not_
supported by `nextstrain run`.

### Deploying build

To run the workflow and automatically deploy the build to nextstrain.org,
you will need to have AWS credentials to run the following:

```
nextstrain build \
    --env AWS_ACCESS_KEY_ID \
    --env AWS_SECRET_ACCESS_KEY \
    . \
        deploy_all \
        --configfile build-configs/nextstrain-automation/config.yaml
```

[Pathoplexus]: https://pathoplexus.org
[Pathoplexus data use terms]: https://pathoplexus.org/about/terms-of-use/data-use-terms
[RESTRICTED data]: https://pathoplexus.org/about/terms-of-use/restricted-data
