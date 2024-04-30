
# Measles Nextclade Dataset Tree

This workflow creates a phylogenetic tree that can be used as part of a Nextclade dataset to assign genotypes to measles samples based on [criteria outlined by the WHO](https://www.who.int/publications/i/item/WER8709). 

The WHO has defined 24 measles genotypes based on N gene and H gene sequences from 28 reference strains. For new measles samples, genotypes can be assigned based on genetic similarity to the reference strains at the "N450" region (a 450 bp region of the N gene). 

The tree created here includes N450 sequences for the 28 reference strains, along with other representative strains for each genotype. 

The workflow includes the following steps:
* Build a tree using samples from the `ingest` output, with the following sampling criteria:
	* Exclude samples for which a genotype is NOT present on NCBI (indicated in the metadata column "genotype_ncbi")
	* Force-include the following samples:
		* WHO genotype reference strains
		* Vaccine strains
		* All available samples for genotypes that are poorly represented on NCBI (i.e., genotypes that have fewer than 10 samples on NCBI)
	* Subsampling criteria:
	  * group_by: "region genotype_ncbi year"
      * subsample_max_sequences: 500
	  * min_date: 1950
      * min_length: 400
* Assign genotypes to each sample and internal nodes of the tree with `augur clades`, using clade-defining mutations in `defaults/clades.tsv`
* Provide the following coloring options on the tree:
	* WHO reference strains ("True" or "False")
	* Genotype assignment from `augur clades`
	* Genotype assignment reported on NCBI

## How to create a new tree:
* Run the workflow: `nextstrain build .`
* Inspect the output tree by comparing genotype assignments from the following sources:
	* WHO reference strains
	* `augur clades` output
	* NCBI Datasets output
* If unwanted samples are present in the tree, add them to `defaults/dropped_strains.tsv` and re-run the workflow
* If any changes are needed to the clade-defining mutations, add changes to `defaults/clades.tsv` and re-run the workflow
* Repeat as needed
