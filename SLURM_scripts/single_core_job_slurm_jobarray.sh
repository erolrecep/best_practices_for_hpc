#!/bin/bash
#SBATCH --job-name=good_array
#SBATCH --array=1-100%10
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00

# Runs 100 tasks concurrently (max 10 at once)
echo "Running task ID: $SLURM_ARRAY_TASK_ID"
python my_single_thread_script.py
