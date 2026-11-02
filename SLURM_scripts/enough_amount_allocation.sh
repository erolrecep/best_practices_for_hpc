#!/bin/bash
#SBATCH --job-name=mem_smart
#SBATCH --mem=16G 
# Job starts quickly. Validated using `seff` 
# from a previous run.

python data_process.py
