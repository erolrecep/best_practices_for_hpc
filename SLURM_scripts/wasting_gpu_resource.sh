#!/bin/bash
#SBATCH --job-name=gpu_waste
#SBATCH --gres=gpu:4
#SBATCH --time=24:00:00

# The Python script is only coded to use cuda:0.
# 3 H100 GPUs sit idle while others wait in queue.
python train_model.py
