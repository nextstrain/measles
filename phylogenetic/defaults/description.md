We gratefully acknowledge the authors, originating and submitting laboratories of the genetic sequences and metadata for sharing their work. Please note that although data generators have generously shared data in an open fashion, that does not mean there should be free license to publish on this data. Data generators should be cited where possible and collaborations should be sought in some circumstances. Please try to avoid scooping someone else's work. Reach out if uncertain.

We maintain two views of measles evolution:

The first is [`measles/genome`](https://nextstrain.org/measles/genome), which uses full genome sequences.

The second is [`measles/N450`](https://nextstrain.org/measles/N450), which uses a 450bp region of the N gene ("N450") that is frequently sequenced for measles. Since many more N450 sequences are available on NCBI GenBank than full genome sequences, the N450 phylogeny incorporates more samples than the full genome phylogeny. This phylogeny also includes the [28 reference strains that the WHO has used to define measles genotypes](https://iris.who.int/bitstream/handle/10665/241889/WER8709_73-80.PDF?sequence=1).

#### Analysis
Our bioinformatic processing workflow can be found at [github.com/nextstrain/measles](https://github.com/nextstrain/measles) and includes:
- sequence alignment by [augur align](https://docs.nextstrain.org/projects/augur/en/stable/usage/cli/align.html) for full genome sequences and [nextclade](https://docs.nextstrain.org/projects/nextclade/en/stable/) for N450 sequences
- phylogenetic reconstruction using [IQTREE-2](http://www.iqtree.org/)
- ancestral state reconstruction and temporal inference using [TreeTime](https://github.com/neherlab/treetime)
- genotype assignment using the [measles/N450/WHO-2012 Nextclade dataset](https://clades.nextstrain.org/?dataset-name=nextstrain/measles/N450/WHO-2012) based on [genotype definitions provided by the WHO](https://iris.who.int/bitstream/handle/10665/241889/WER8709_73-80.PDF?sequence=1)

#### Underlying data
We curate sequence data and metadata from NCBI as starting point for our analyses. Curated sequences and metadata are available as flat files at:
- [data.nextstrain.org/files/workflows/measles/sequences.fasta.zst](https://data.nextstrain.org/files/workflows/measles/sequences.fasta.zst)
- [data.nextstrain.org/files/workflows/measles/metadata.tsv.zst](https://data.nextstrain.org/files/workflows/measles/metadata.tsv.zst)

Pairwise alignments with [Nextclade](https://docs.nextstrain.org/projects/nextclade/en/stable) against the N450 region of [reference sequence Ichinose-B95a](https://www.ncbi.nlm.nih.gov/nuccore/NC_001498.1), clade assignments, and N450 region quality control metrics and translations are available at
- [data.nextstrain.org/files/workflows/measles/alignment.fasta.zst](https://data.nextstrain.org/files/workflows/measles/alignment.fasta.zst)
- [data.nextstrain.org/files/workflows/measles/nextclade.tsv.zst](https://data.nextstrain.org/files/workflows/measles/nextclade.tsv.zst)
- [data.nextstrain.org/files/workflows/measles/translations.zip](https://data.nextstrain.org/files/workflows/measles/translations.zip)

---

Screenshots may be used under a [CC-BY-4.0 license](https://creativecommons.org/licenses/by/4.0/) and attribution to nextstrain.org must be provided.
