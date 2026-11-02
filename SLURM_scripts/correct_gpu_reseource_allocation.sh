#!/bin/bash
#SBATCH --job-name=gpu_optimized
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00

# Loads Apptainer container with PyTorch
apptainer exec --nv my_pytorch.sif python train_model.py

# (If using 4 GPUs, script MUST use 
# DistributedDataParallel or similar).
