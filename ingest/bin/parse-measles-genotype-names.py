#! /usr/bin/env python3
"""
From stdin, parses genotypes from GenBank's 'virus-name' field of the NDJSON record to 'genotype_ncbi'

Outputs the modified record to stdout.
"""

import argparse
import json
from sys import stdin, stdout, stderr

import re

EXPECTED_GENOTYPES = ['A', 'B1', 'B2', 'B3', 'C1', 'C2', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'E', 'F', 'G1', 'G2', 'G3', 'H1', 'H2']

def parse_args():
    parser = argparse.ArgumentParser(
        description="Modify measles virus-name attribute to extract genotypes to 'genotype_ncbi'."
    )
    parser.add_argument("--genotype-field", default='virus_name',
        help="Field from the records to use as the genotype to be parsed.")

    return parser.parse_args()

def _set_genotype_name(record):
    genotype_name = record["genotype_ncbi"]

    genotype_name = genotype_name.replace('Measles virus genotype ', '')
    genotype_name = re.sub(r'Measles morbillivirus.*$', r'', genotype_name)
    genotype_name = re.sub(r'.*?\[(.*)\]$', r'\1', genotype_name) # If square brackets present at end of string, keep only the text inside the brackets
    genotype_name = re.sub(r'Measles virus MVs.*$', r'', genotype_name)
    genotype_name = re.sub(r'Measles virus MVi.*$', r'', genotype_name)
    genotype_name = re.sub(r'Measles virus strain MVi.*$', r'', genotype_name)
    genotype_name = genotype_name.replace('Measles virus strain ', '')
    genotype_name = re.sub(r'Measles virus.*$', r'', genotype_name)
    genotype_name = re.sub(r'A-vaccine.*$', r'A', genotype_name)
    genotype_name = re.sub(r'B3.1', r'B3', genotype_name)
    genotype_name = re.sub(r'B3.2', r'B3', genotype_name)
    genotype_name = re.sub(r'D4a', r'D4', genotype_name)
    genotype_name = re.sub(r'D4b', r'D4', genotype_name)
    genotype_name = re.sub(r'H1a', r'H1', genotype_name)
    genotype_name = re.sub(r'H1b', r'H1', genotype_name)

    return (
        genotype_name)

def main():
    args = parse_args()

    for index, record in enumerate(stdin):
        record = json.loads(record)
        record['genotype_ncbi'] = record[args.genotype_field]
        record['genotype_ncbi'] = _set_genotype_name(record)
        if record['genotype_ncbi'] not in EXPECTED_GENOTYPES:
            print(f"WARNING: unexpected NCBI genotype {record['genotype_ncbi']} parsed from record {index} will be excluded.", file=stderr)
            record['genotype_ncbi'] = ''
        stdout.write(json.dumps(record) + "\n")

if __name__ == "__main__":
    main()
