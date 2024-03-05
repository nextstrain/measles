#! /usr/bin/env python3
"""
Parses GenBank's 'strain' field of the NDJSON record from stdin and applies measles-specific strain name corrections
based on historical modifications from the fauna repo.

Outputs the modified record to stdout.
"""

import argparse
import json
from sys import stdin, stdout

import re

def parse_args():
    parser = argparse.ArgumentParser(
        description="Modify measles strain names by referencing historical modifications from the fauna repo."
    )
    parser.add_argument("--genotype-field", default='virus_name',
        help="Field from the records to use as the strain name to be fixed.")

    return parser.parse_args()


def _set_genotype_name(record):
    """Replace spaces, dashes, and periods with underscores in strain name."""
    genotype_name = record["virus_name"]
    
    genotype_name = genotype_name.replace('Measles virus genotype ', '')
    genotype_name = re.sub(r'Measles morbillivirus.*$', r'', genotype_name)   
    genotype_name = re.sub(r'.*?\[(.*)\]$', r'\1', genotype_name)
    genotype_name = re.sub(r'Measles virus MVs.*$', r'', genotype_name)
    genotype_name = re.sub(r'Measles virus MVi.*$', r'', genotype_name)
    genotype_name = re.sub(r'Measles virus strain MVi.*$', r'', genotype_name)
    genotype_name = genotype_name.replace('Measles virus strain ', '')
    genotype_name = re.sub(r'Measles virus.*$', r'', genotype_name)
    #genotype_name = re.sub(r'A-vaccine.*$', r'', genotype_name)
    #genotype_name = re.sub(r'N.*$', r'', genotype_name)

    return (
        genotype_name)

def main():
    args = parse_args()

    for index, record in enumerate(stdin):
        record = json.loads(record)
        record[args.genotype_field] = _set_genotype_name(record)
        stdout.write(json.dumps(record) + "\n")


if __name__ == "__main__":
    main()
