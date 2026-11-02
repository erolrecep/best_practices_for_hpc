#!/bin/bash
#SBATCH --job-name=bad_seq
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --time=48:00:00

# Wastes 63 cores if the script is single-threaded
python my_single_thread_script.py param1
python my_single_thread_script.py param2
