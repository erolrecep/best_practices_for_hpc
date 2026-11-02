#!/bin/bash
#SBATCH --job-name=mem_hog
#SBATCH --mem=128G 
# Job stays pending in queue for days for resources
# it doesn't actually need.

python data_process.py
