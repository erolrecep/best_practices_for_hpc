+++
title = "Best Practices for Using HPC: Scaling Up to Cluster-Native Workflows"
date = 2026-11-02T12:00:00-06:00
tags = ["High Performance Computing", "Slurm", "GPU Computing", "Scientific Workflows", "Reproducibility", "Apptainer", "Performance Optimization"]
categories = ["High Performance Computing", "Scientific Computing"]
+++

*Moving Beyond the Laptop Mindset: A Practical Guide for Researchers and Computational Scientists*

---

## Abstract

Unlocking the full potential of advanced computational infrastructure requires moving beyond the mindset of simply scaling up local code. While transitioning from a personal workstation or Google Colab notebook to a shared High-Performance Computing (HPC) cluster removes local compute and memory bottlenecks, true acceleration is achieved only by adopting **cluster-native workflows**. 

Modern supercomputing systems are not simply bigger laptops; they are orchestrated, multi-tenant community ecosystems governed by batch schedulers, distributed parallel filesystems, and specialized hardware accelerators. Navigating these environments demands an operational paradigm shift. 

This guide—developed from my hands-on workshops and daily engineering consultations—provides an in-depth, practical roadmap to mastering cluster-native computing. We examine the shared resource model, data transfer logistics, containerized reproducibility with Apptainer, and dissect **three pervasive Slurm anti-patterns** (the Memory Trap, the Sequential Loop Trap, and the Multi-GPU Hoarding Trap) with side-by-side script refactorings. Finally, we establish observability workflows using `seff` and `nvtop` to audit hardware efficiency and accelerate time-to-discovery.

> 📊 **Interactive Slide Deck**: You can explore the accompanying 16-slide workshop presentation directly at:  
> [**https://erolrecep.github.io/best-practices-hpc/**](https://erolrecep.github.io/best-practices-hpc/)

---

## 1. The Core Paradigm Shift: Laptop vs. Supercomputer

In empirical science, computational researchers routinely encounter the limits of personal hardware: an out-of-memory error during data ingestion, thermal throttling during model training, or an execution time spanning weeks. Transitioning to an institutional supercomputer (such as Rice University's **RANGE** cluster, equipped with NVIDIA H100/H200 GPUs and VAST high-speed parallel storage) resolves raw capacity limits.

However, researchers frequently bring their personal workstation habits directly into the cluster, creating severe operational friction.

<div style="background: rgba(56, 189, 248, 0.08); border-left: 4px solid #0284c7; padding: 1rem 1.5rem; border-radius: 0 8px 8px 0; margin: 1.5rem 0; font-size: 0.95rem; color: #0369a1;">
  <strong>The Fundamental Rule:</strong> An HPC cluster is an autonomous batch-processing factory, not an interactive personal playground.
</div>

| Dimension | Personal Workstation / Laptop | Shared HPC Supercomputer |
| :--- | :--- | :--- |
| **Ownership** | Dedicated (100% of CPU and RAM is yours) | Shared (Hundreds of researchers compete for nodes) |
| **Execution** | Synchronous & Interactive (Click run, view stdout) | Asynchronous & Batch-Scheduled (Slurm priority queues) |
| **Filesystem** | Local NVMe/SSD; desktop writes are harmless | Distributed parallel storage (VAST NVMe / Lustre) |
| **Lifecycle** | Sleep/restart kills active jobs | Detached background jobs run 24/7 autonomously |
| **Failure Cost** | Only impacts your local session | Over-allocation blocks entire research groups |

Understanding this distinction transforms how you design pipelines: **develop and debug on minimal subsets locally or interactively, then dispatch self-contained, automated batch jobs to the cluster.**

---

## 2. Accessing the Cluster: Login Node Etiquette

When you connect to an HPC cluster via SSH, you land on a **Login Node** (also referred to as a head node). 

### The Golden Rule
> **Never execute computational workloads, heavy data processing, or background language server processes on login nodes.**

Login nodes are shared gateway servers configured with limited compute capacity. Their sole purpose is:
- Navigating the filesystem and editing configuration files.
- Managing code via Git.
- Inspecting queue status (`squeue`) and managing jobs (`sbatch`, `scancel`).

### The Hidden Trap: Remote IDE Servers
A modern anti-pattern is opening remote VS Code or Cursor directly connected to the login node. Default IDE extensions spawn aggressive background indexing processes, language servers, and AI copilots that saturate CPU cores and exhaust memory on the head node, degrading responsiveness for every user on the system.

### The Cluster-Native Solution
For exploratory data analysis, interactive debugging, or running IDEs:
1. **Interactive Slurm Allocations**: Request an interactive shell directly on a compute node:
   ```bash
   salloc --cpus-per-task=4 --mem=16G --time=02:00:00
   ```
2. **OpenOnDemand (OOD)**: Use the web-based OpenOnDemand portal to launch dedicated, containerized JupyterLab or MATLAB instances backed by real compute node allocations.
3. **Production Runs**: Submit non-interactive batch scripts using `sbatch`.

---

## 3. High-Performance Data Logistics & Storage Hygiene

Data movement and storage architecture represent the second major bottleneck for computational researchers.

### Moving Data at Scale: `rsync` vs. Globus
Moving a few megabytes is trivial, but migrating multi-terabyte datasets across institutions requires protocol awareness:

```
                           DATA TRANSFER STRATEGY
                                     │
                 ┌───────────────────┴───────────────────┐
                 ▼                                       ▼
      Small to Medium (< 100 GB)                 Massive (Multi-TB)
                 │                                       │
                 ▼                                       ▼
       Incremental Terminal Sync                High-Throughput GridFTP
            [ rsync / scp ]                         [ Globus Transfer ]
                 │                                       │
     • Resumes interrupted transfers         • Science DMZ 100GbE engine
     • Preserves timestamps (-a)             • End-to-end SHA256 checksums
     • Filters cache files (--exclude)       • Background detached execution
```

For incremental synchronization of code, configuration files, or preprocessed datasets:
```bash
# Robust rsync with resume capability and timestamp preservation
rsync -avzP --exclude '*.tmp' --exclude '__pycache__' \
  ./project_data/ re51@range.rice.edu:/scratch/re51/data/
```

For multi-terabyte dataset ingest, **Globus Transfer** is essential: it leverages high-speed Science DMZ network switches, handles connection dropouts automatically, and performs background checksum verification without requiring your local terminal to stay connected.

---

### Understanding HPC Storage Tiers

Supercomputers partition storage into distinct tiers, each optimized for specific access patterns:

1. **Home Directory (`~/home`)**:
   - **Characteristics**: Strict quotas (typically 20–50 GB), daily enterprise backups.
   - **Intended Use**: Shell dotfiles, SSH keys, virtual environment definitions, Git repositories.
   - **Anti-Pattern**: Writing simulation checkpoints, PyTorch cache directories, or uncompressed raw datasets here will instantly exhaust your quota and lock your shell.
2. **Scratch Storage (`/scratch`)**:
   - **Characteristics**: Multi-petabyte parallel NVMe (e.g., VAST Data or Lustre) with multi-GB/s read/write bandwidth.
   - **Intended Use**: High-frequency checkpointing, active job I/O, uncompressed temporary arrays.
   - **The Hygiene Rule**: Scratch is **ephemeral compute storage, not a permanent lab archive**. Automated purge policies clean old files. Always archive essential results and delete scratch intermediates post-run.
3. **Project / Lab Archive**:
   - **Characteristics**: High-capacity network storage shared across your research group.
   - **Intended Use**: Final curated datasets, model weights, and publication artifacts.

#### Beware the "Million Tiny Files" Trap
Parallel filesystems excel at sequential streaming of large contiguous blocks (e.g., 50 GB HDF5 or binary tensor files). Storing 1,000,000 loose 10 KB JPEG files overburdens the parallel metadata servers (MDT), causing directory listings (`ls`) and file opens to grind to a halt. Always bundle small files into archives (`.tar`), HDF5 containers, or WebDataset formats.

---

## 4. Reproducible Environments: Packaging with Apptainer

One of the most frequent support tickets in scientific computing reads: *"It runs perfectly on my laptop, but fails on the cluster."*

Underlying differences in glibc versions, CUDA toolkits, and conflicting Python pip wheels are the culprits. The cluster-native solution is **containerization** via **Apptainer** (formerly Singularity).

```
   ┌────────────────────────────────────────────────────────┐
   │             Self-Contained Scientific Container        │
   │                      (my_model.sif)                    │
   │  ┌──────────────────────────────────────────────────┐  │
   │  │ Application Code & Dependencies (Python 3.13)    │  │
   │  ├──────────────────────────────────────────────────┤  │
   │  │ Machine Learning Frameworks (PyTorch 2.4, CUDA)  │  │
   │  ├──────────────────────────────────────────────────┤  │
   │  │ OS System Libraries & Binaries (Ubuntu 22.04 LTS)│  │
   │  └──────────────────────────────────────────────────┘  │
   └───────────────────────────┬────────────────────────────┘
                               │ Directly binds GPU via --nv
                               ▼
   ┌────────────────────────────────────────────────────────┐
   │             HPC Host Compute Node (RANGE)              │
   │          Linux Kernel + NVIDIA Driver Layer            │
   └────────────────────────────────────────────────────────┘
```

### Why Apptainer Excels on HPC:
- **No Root Required**: Executes entirely in unprivileged user space.
- **Hardware Acceleration**: The `--nv` flag automatically exposes host NVIDIA kernel drivers and CUDA runtime devices into the container.
- **Native Filesystem Mounts**: Directly mount `/scratch` and `/home` without copying data.

### Slurm Execution Example:
```bash
#!/bin/bash
#SBATCH --job-name=container_train
#SBATCH --gres=gpu:1
#SBATCH --time=12:00:00

# Execute PyTorch workload inside Apptainer
apptainer exec --nv \
  --bind /scratch/re51:/scratch \
  /scratch/re51/containers/pytorch_2.4.sif \
  python3 /scratch/re51/code/train.py --data-dir /scratch/re51/dataset
```

Pairing your container with a root `Makefile` ensures that running `make train` executes the identical recipe regardless of whether it is tested on your local workstation or submitted on RANGE.

---

## 5. Slurm Resource Sizing: The Three Costly Traps

Resource allocation is the operational heart of High-Performance Computing. Because an HPC cluster is a shared, finite resource, Slurm prioritizes jobs based on backfill scheduling algorithms. Over-requesting resources exponentially inflates queue wait times.

Here are the three most common Slurm anti-patterns and their refactored cluster-native solutions:

---

### Anti-Pattern 1: The Memory Over-Allocation Trap

Researchers often request massive amounts of memory "just to be safe." 

```
❌ MEMORY TRAP: Requesting 128 GB for a 16 GB job
────────────────────────────────────────────────────────────────────────
Slurm Scheduler: "I need to find a single node with 128 GB of idle RAM."
Result: Job sits in PENDING state for 48 hours waiting for a node to drain.
Actual Utilization: Script peaks at 12.4 GB. 115.6 GB RAM is wasted.

✅ CLUSTER-NATIVE: Requesting 16 GB based on profiling
────────────────────────────────────────────────────────────────────────
Slurm Scheduler: "A 16 GB fragment is available on node range-cn042 right now."
Result: Job starts within 3 minutes. Memory efficiency reaches 85%.
```

#### Code Comparison:
```bash
# ❌ BAD: over_allocation_bad_example.sh
#!/bin/bash
#SBATCH --job-name=mem_hog
#SBATCH --mem=128G 
# Job stays pending in queue for days for resources it doesn't need.
python data_process.py

# ✅ GOOD: enough_amount_allocation.sh
#!/bin/bash
#SBATCH --job-name=mem_smart
#SBATCH --mem=16G 
# Starts quickly; validated using `seff` from a preliminary test run.
python data_process.py
```

---

### Anti-Pattern 2: The Sequential Execution Loop Trap

Another common pitfall is submitting a single job script requesting a multi-core node (e.g., 64 CPU cores), inside of which a single-threaded Python script runs 100 simulations sequentially in a `for` loop.

```bash
# ❌ BAD: single_core_job_full_allocate.sh
#!/bin/bash
#SBATCH --job-name=bad_seq
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --time=48:00:00

# Wastes 63 CPU cores if the Python script is single-threaded!
python my_single_thread_script.py param1
python my_single_thread_script.py param2
```

In this scenario, you occupy 64 cores for 48 hours, but 63 cores sit at 0% utilization.

#### The Cluster-Native Solution: Slurm Job Arrays
Slurm Job Arrays allow you to submit hundreds of independent parameter tasks under a single job ID, orchestrating true concurrent execution:

```bash
# ✅ GOOD: single_core_job_slurm_jobarray.sh
#!/bin/bash
#SBATCH --job-name=good_array
#SBATCH --array=1-100%10
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00

# Runs 100 tasks concurrently (maximum 10 running at any single moment)
echo "Executing task index: $SLURM_ARRAY_TASK_ID"
python my_single_thread_script.py --run-id "$SLURM_ARRAY_TASK_ID"
```

- Each task requests only **1 CPU core and 4 GB of RAM**, allowing Slurm to scatter tasks across available node gaps immediately.
- The `%10` throttle prevents overwhelming filesystems while providing a **10x wall-clock speedup** over sequential execution.

---

### Anti-Pattern 3: The Multi-GPU Hoarding Trap

Modern GPU accelerators (such as NVIDIA H100 and H200) represent substantial capital investments and are in high demand across research institutions.

A frequent error is requesting 4 GPUs (`--gres=gpu:4`) in the Slurm header for a script that is written for a single CUDA device:

```python
# train_model.py
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model.to(device)  # Only utilizes GPU 0!
```

```bash
# ❌ BAD: wasting_gpu_resource.sh
#!/bin/bash
#SBATCH --job-name=gpu_waste
#SBATCH --gres=gpu:4
#SBATCH --time=24:00:00

# Locks 4 GPUs, but the Python script only sends tensors to cuda:0.
# 3 H100 GPUs sit at 0% load while other researchers wait in queue.
python train_model.py
```

#### The Cluster-Native Solution:
If your script is not explicitly engineered with `torch.distributed.run` and `DistributedDataParallel` (DDP), request exactly **1 GPU**:

```bash
# ✅ GOOD: correct_gpu_reseource_allocation.sh
#!/bin/bash
#SBATCH --job-name=gpu_optimized
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00

# High-priority scheduling, 100% GPU saturation
apptainer exec --nv my_pytorch.sif python train_model.py
```

---

## 6. Observability & Profiling: Know Your Hardware Utilization

You cannot optimize what you do not measure. Slurm and modern Linux environments provide built-in telemetry tools to audit job performance.

### Post-Mortem Auditing with `seff`
After any Slurm batch job terminates, run `seff <jobid>` to view a concise summary of CPU and memory efficiency:

```text
$ seff 4819201
Job ID: 4819201
Cluster: range
State: COMPLETED (exit code 0)
Nodes: 1
Cores: 8
CPU Utilized: 02:45:12
CPU Efficiency: 89.2% of 03:05:12 core-walltime
Memory Utilized: 14.21 GB
Memory Efficiency: 88.8% of 16.00 GB
```

> 🎯 **Rule of Thumb**: If your **Memory Efficiency is below 30%**, reduce `--mem` in your next submission. If **CPU Efficiency is low**, verify your multi-threading flags (e.g., `OMP_NUM_THREADS` or PyTorch `num_workers`).

### Live Telemetry During Interactive Allocations
When running inside an interactive `salloc` session, observe real-time resource saturation:
- **`nvtop`**: An interactive, visual GPU process monitor showing per-GPU compute engine %, memory bandwidth, and power draw.
- **`nvidia-smi dmon -s pucvmet`**: Text-based periodic device telemetry.
- **`htop`**: Per-core CPU load and thread distribution.

Always execute a brief 5-minute sanity test interactively to verify GPU saturation before submitting a 48-hour batch job.

---

## 7. Project Hygiene: Structuring Run Directories & Slurm Logs

Avoid dumping standard output and error logs into your root home directory. Adopt a structured directory blueprint:

```text
my_scientific_project/
├── Makefile                   # Automated workflow entry points
├── requirements.txt           # Python dependency lockfile
├── container.sif              # Apptainer container image
├── src/                       # Application source code
├── sbatch/                    # Parameterized Slurm submission scripts
│   ├── 01_preprocess.slurm
│   └── 02_train_array.slurm
└── results/                   # Log outputs organized by Job ID
    ├── train_array_48210_1.out
    └── train_array_48210_1.err
```

In your Slurm scripts, always parameterize output filenames:
```bash
# Route output and errors automatically using job name (%x) and job ID (%j)
#SBATCH --output=results/%x_%j.out
#SBATCH --error=results/%x_%j.err

# Receive email alerts on failure or completion
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=re51@rice.edu
```

---

## 8. Conclusion: We Are Partners in Discovery

Scaling computational research from a personal workstation to an institutional supercomputer is an iterative skill. The operational best practices outlined here—resource right-sizing, containerized portability, storage hygiene, and batch parallelization—form the technical bedrock of modern computational science.

As computational scientists and research software engineers, we are here to support your scientific breakthroughs. Engage with the **Center for Research Computing (CRC)** early during experimental design, rather than solely when pipeline errors occur:

- **Open Office Hours**: Every Tuesday (10:00 AM – 12:00 PM & 1:00 PM – 3:00 PM). Drop in with your code, Slurm scripts, or scaling bottlenecks.
- **Helpdesk & Ticketing**: Contact `helpdesk@rice.edu` or submit through the Service Now portal for cluster, GPU, and software support.
- **1-on-1 Engineering Consultations**: Arrange dedicated technical sessions to co-design multi-node distributed pipelines, PyTorch DDP acceleration, or Slurm job array automation.

Let's build scalable, reproducible, and cluster-native science together.

---

### Resources & Presentation Links

- **Interactive Presentation Deck**: [https://erolrecep.github.io/best-practices-hpc/](https://erolrecep.github.io/best-practices-hpc/)
- **Workshop Source Repository**: [https://github.com/erolrecep/best_practices_for_hpc](https://github.com/erolrecep/best_practices_for_hpc)
- **Author Portfolio & Blog**: [https://erolrecep.github.io/](https://erolrecep.github.io/)
- **Rice Center for Research Computing**: [https://researchcomputing.rice.edu/](https://researchcomputing.rice.edu/)
- **Rice HPC Documentation**: [https://kb.rice.edu/](https://kb.rice.edu/)
