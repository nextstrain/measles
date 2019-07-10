#!/bin/sh
#
#SBATCH --time=05:59:59
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#

# activate conda environment
source /scicore/home/neher/neher/miniconda3/etc/profile.d/conda.sh
conda activate augur
export AUGUR_MINIFY_JSON=1

{exec_job}


