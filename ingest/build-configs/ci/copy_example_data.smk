rule copy_example_data:
    input:
        ncbi_dataset="example_data/ncbi_dataset.zip"
    output:
        ncbi_dataset=temp("data/ncbi_dataset.zip")
    shell:
        """
        cp -f {input.ncbi_dataset} {output.ncbi_dataset}
        """

# Add a Snakemake ruleorder directive here if you need to resolve ambiguous rules
# that have the same output as the copy_example_data rule.

ruleorder: copy_example_data > fetch_ncbi_dataset_package
