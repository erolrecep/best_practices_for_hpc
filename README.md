# Best Practices for Using HPC: Scaling Up to Cluster-Native Workflows

<p align="center">
  <a href="https://erolrecep.github.io/best-practices-hpc/"><img src="https://img.shields.io/badge/Slides-Reveal.js-38bdf8.svg?logo=revealdotjs&logoColor=white" alt="Interactive Slides"></a>
  <img src="https://img.shields.io/badge/HPC-SLURM_Ready-blueviolet.svg" alt="HPC">
  <img src="https://img.shields.io/badge/Containers-Apptainer-purple.svg" alt="Apptainer">
  <img src="https://img.shields.io/badge/Build-Make-orange.svg?logo=gnu&logoColor=white" alt="Make">
  <a href="https://erolrecep.github.io/posts/best-practices-for-hpc/"><img src="https://img.shields.io/badge/Blog-erolrecep.github.io-red.svg" alt="Blog"></a>
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</p>

> **Live Links & Quick Navigation:**
> - 🖥️ **Interactive Slide Deck**: [https://erolrecep.github.io/best-practices-hpc/](https://erolrecep.github.io/best-practices-hpc/)
> - 📖 **Technical Long-Form Blog Post**: [https://erolrecep.github.io/posts/best-practices-for-hpc/](https://erolrecep.github.io/posts/best-practices-for-hpc/)
> - 📦 **GitHub Repository**: [https://github.com/erolrecep/best_practices_for_hpc](https://github.com/erolrecep/best_practices_for_hpc)

---

## 1. About This Initiative

In modern empirical science, computational researchers routinely encounter the limits of personal hardware: out-of-memory errors during data ingestion, thermal throttling during model training, or execution times spanning weeks. Transitioning from a laptop or Google Colab notebook to an institutional supercomputer (such as Rice University's **RANGE** cluster, equipped with NVIDIA H100 and H200 GPUs interconnected with NDR networking) removes raw capacity limits.

However, researchers frequently bring their personal workstation habits directly into the cluster, creating severe operational friction: running heavy interactive IDE servers on login nodes, requesting massive memory allocations that cause days of queue wait time, or locking multi-GPU nodes for single-threaded Python scripts.

This repository serves as an **open educational hub, workshop presentation, and practical Slurm guide** created as an independent volunteer initiative by **Dr. Recep Erol** (Computational Scientist for AI, Center for Research Computing, Rice University). It provides computational researchers, graduate students, and postdocs with an operational roadmap to transition to **cluster-native workflows**.

---

## 2. Directory Layout & Repository Structure

```
apps/_hpc/best_practices_for_hpc/
├── index.html                     # Main Reveal.js presentation (16 interactive slides)
├── Makefile                       # Single-file management console (make slides, check, export-pdf)
├── README.md                      # Comprehensive workshop guide and repository overview
├── LICENSE                        # MIT License
├── blog_post.md                   # Full publication-ready technical blog post
├── about_me.html                  # Modular presenter bio snippet (from VibeCoding-Workshop)
├── images/
│   └── avatar.jpeg                # Presenter portrait for profile cards
└── SLURM_scripts/                 # Concrete side-by-side Slurm comparisons
    ├── over_allocation_bad_example.sh      # ❌ Trap 1: Requesting 128 GB RAM for a 16 GB job
    ├── enough_amount_allocation.sh         # ✅ Solution 1: 16 GB right-sizing with seff audit
    ├── single_core_job_full_allocate.sh    # ❌ Trap 2: Allocating 64 cores for a serial loop
    ├── single_core_job_slurm_jobarray.sh   # ✅ Solution 2: Concurrent execution via Slurm Job Arrays
    ├── wasting_gpu_resource.sh             # ❌ Trap 3: Locking 4 GPUs for single-stream cuda:0 code
    └── correct_gpu_reseource_allocation.sh # ✅ Solution 3: Targeted 1-GPU + Apptainer container
```

---

## 3. The 5 Pillars of Cluster-Native Workflows

The workshop and technical guide are organized around five core pedagogical modules:

### Pillar 1: The Mindset Shift (Laptop vs. Supercomputer)
An HPC cluster is an autonomous batch factory, not a larger personal workstation. 
- **Login Node Etiquette**: Login nodes are gateway servers for navigation and job dispatch only. Heavy data processing, compiling, or background IDE indexing (VS Code Remote Server, Copilot) are strictly forbidden.
- **Interactive vs. Batch**: Use `salloc` or OpenOnDemand (OOD) for exploratory data analysis; use non-interactive `sbatch` scripts for production runs.

### Pillar 2: High-Performance Data Logistics & Storage Hygiene
- **Data Transfer**: Use `rsync` for incremental syncs of code and configurations; leverage **Globus Transfer** on the 100GbE Science DMZ for multi-terabyte datasets.
- **Storage Tiers**: Home (`~/home`, 20–50 GB quota) is strictly for dotfiles and Git repositories. Compute runs belong in Scratch (`/scratch`, parallel VAST NVMe), where purge policies require cleaning intermediate files post-job.
- **The Million Tiny Files Trap**: Parallel filesystems bottleneck on millions of loose 10 KB files. Always bundle datasets into `.tar`, HDF5, or WebDataset formats.

### Pillar 3: Reproducible Environments with Apptainer
- Eliminate "works on my laptop" discrepancies by packaging dependencies, system libraries, and CUDA into portable **Apptainer (Singularity)** `.sif` containers.
- The `--nv` flag automatically binds host NVIDIA drivers and CUDA runtimes into the container without requiring root privileges.
- Pair containers with project `Makefile` targets (`make train`) so execution recipes remain identical locally and on the cluster.

### Pillar 4: Sizing Slurm Allocations: The 3 Anti-Patterns
Dissecting the three most costly queue and hardware utilization pitfalls, backed by the scripts in `SLURM_scripts/` (see comparison table below).

### Pillar 5: Observability, Profiling & Collaboration
- **Post-Mortem Auditing**: Inspect real CPU and memory efficiency using `seff <jobid>`. If memory efficiency is below 30%, reduce `--mem`.
- **Live Telemetry**: Monitor GPU saturation, memory bandwidth, and compute usage during interactive sessions with `nvtop` and `nvidia-smi`.
- **CRC Partnership**: Engage with the Center for Research Computing during experimental co-design; drop in for Open Office Hours every Tuesday.

---

## 4. Slurm Anti-Patterns vs. Best Practices Reference

| Anti-Pattern | Bad Script (`SLURM_scripts/`) | The Cost / Consequence | Cluster-Native Solution (`SLURM_scripts/`) | Operational Benefit |
| :--- | :--- | :--- | :--- | :--- |
| **Trap 1: The Memory Over-Allocation Trap** | [`over_allocation_bad_example.sh`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/SLURM_scripts/over_allocation_bad_example.sh)<br/>`#SBATCH --mem=128G` | Job sits in `PENDING` status for 48+ hours waiting for a massive RAM block to drain. Script only uses 12.4 GB. 115 GB RAM wasted. | [`enough_amount_allocation.sh`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/SLURM_scripts/enough_amount_allocation.sh)<br/>`#SBATCH --mem=16G` | Slurm backfills the 16 GB request into available node gaps immediately. Queue wait drops to minutes; memory efficiency reaches 85%. |
| **Trap 2: The Sequential Loop Trap** | [`single_core_job_full_allocate.sh`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/SLURM_scripts/single_core_job_full_allocate.sh)<br/>`#SBATCH --nodes=1`<br/>`#SBATCH --ntasks=64` | Allocates 64 CPU cores for 48 hours, but runs a single-threaded Python script sequentially. 63 CPU cores idle at 0% load. | [`single_core_job_slurm_jobarray.sh`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/SLURM_scripts/single_core_job_slurm_jobarray.sh)<br/>`#SBATCH --array=1-100%10`<br/>`#SBATCH --cpus-per-task=1` | Concurrently executes 100 parameter tasks (10 running in parallel) using `$SLURM_ARRAY_TASK_ID`. Drops wall-clock runtime by **10x**. |
| **Trap 3: The Multi-GPU Hoarding Trap** | [`wasting_gpu_resource.sh`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/SLURM_scripts/wasting_gpu_resource.sh)<br/>`#SBATCH --gres=gpu:4` | Python script only addresses `cuda:0`. Locks \$120,000 worth of GPUs; 3 H100 accelerators sit completely idle. | [`correct_gpu_reseource_allocation.sh`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/SLURM_scripts/correct_gpu_reseource_allocation.sh)<br/>`#SBATCH --gres=gpu:1`<br/>`apptainer exec --nv ...` | High priority scheduling, 100% GPU saturation. If scaling to 4 GPUs, explicitly engineer and verify with PyTorch DDP first. |

---

## 5. Slide Deck Overview (16 Slides)

The presentation in [`index.html`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/index.html) is built with **Reveal.js 5.1.0** on a 16:9 widescreen HD canvas (`1280x720`) with Monokai syntax highlighting and Google Fonts (`Inter` + `Fira Code`):

1. **Title Slide**: Workshop header, branding, subtitle, presenter credentials.
2. **About Me**: Presenter profile card (avatar, Computational Scientist for AI, CRC affiliation, email, LinkedIn, GitHub, website).
3. **The Narrative Shift**: "We Are Your Partners in Research"—framing HPC support as research collaborators.
4. **Agenda**: The 5 Pillars of Cluster Efficiency.
5. **Pillar 1: Laptop vs. Supercomputer**: Contrast matrix of personal computing vs multi-tenant supercomputers.
6. **Accessing HPC**: Login nodes (strict gateway limits) vs compute nodes (interactive `salloc` / OOD / batch).
7. **Pillar 2: Data Transfer**: Small syncs via `rsync` vs multi-TB Science DMZ transfers via Globus.
8. **Storage Hygiene**: Scratch (VAST NVMe) vs Home vs Archive; avoiding the million tiny files trap.
9. **Pillar 3: Reproducibility**: Containerizing scientific pipelines with Apptainer (`--nv`) and `Makefile` drivers.
10. **Slurm Trap #1 (Memory)**: Side-by-side diff card (`mem_hog` vs `mem_smart`).
11. **Slurm Trap #2 (Sequential)**: Side-by-side diff card (`bad_seq` vs Slurm Job Array `good_array`).
12. **Slurm Trap #3 (GPU Waste)**: Side-by-side diff card (`gpu_waste` vs `gpu_optimized`).
13. **Pillar 5: Observability & Profiling**: Post-mortem audits with `seff` and live telemetry with `nvtop` / `htop`.
14. **Project Layout & Slurm Logging**: Standardizing `%x_%j.out` log routing and project directory structures.
15. **Collaborating with CRC**: Open Office Hours (Tuesdays 10 AM–12 PM & 1 PM–3 PM), ticketing, and 1-on-1 consultations.
16. **Closing & Q&A**: Summary, contact links, and resource pointers.

---

## 6. Local Quickstart & Makefile Commands

A unified [`Makefile`](file:///Users/erolrecep/Developer/codebase/apps/_hpc/best_practices_for_hpc/Makefile) manages presentation serving and verification:

```bash
# Display interactive command menu (default)
make

# Serve presentation at http://localhost:8000 and automatically open browser
make slides

# Serve on a custom port
make slides PORT=8080

# Audit all workshop assets, images, and SLURM comparison scripts
make check

# View step-by-step instructions for exporting high-res PDF slides
make export-pdf
```

---

## 7. Web Publication & Blog Deployment

The materials are published across Dr. Recep Erol's technical web platforms:

### 1. Interactive Slide Deck
- **Published URL**: [https://erolrecep.github.io/best-practices-hpc/](https://erolrecep.github.io/best-practices-hpc/)
- **Source**: [`apps/personal-blog/blog/receps_blog/static/best-practices-hpc/`](file:///Users/erolrecep/Developer/codebase/apps/personal-blog/blog/receps_blog/static/best-practices-hpc/)

### 2. Long-Form Technical Article
- **Published URL**: [https://erolrecep.github.io/posts/best-practices-for-hpc/](https://erolrecep.github.io/posts/best-practices-for-hpc/)
- **Source**: [`apps/personal-blog/blog/receps_blog/content/posts/best-practices-for-hpc/index.md`](file:///Users/erolrecep/Developer/codebase/apps/personal-blog/blog/receps_blog/content/posts/best-practices-for-hpc/index.md)

### Deploying Updates to GitHub Pages:
```bash
cd apps/personal-blog
make deploy
```

---

## 8. Author Contact & CRC Office Hours

- **Author**: **Recep Erol, PhD**
- **Role**: Computational Scientist for AI
- **Affiliation**: [Center for Research Computing (CRC)](https://researchcomputing.rice.edu/) • Rice University
- **Email**: [re51@rice.edu](mailto:re51@rice.edu)
- **LinkedIn**: [linkedin.com/in/erolrecep](https://linkedin.com/in/erolrecep)
- **GitHub**: [github.com/erolrecep](https://github.com/erolrecep)
- **Website & Blog**: [https://erolrecep.github.io](https://erolrecep.github.io)
- **CRC Open Office Hours**: Every Tuesday, **10:00 AM – 12:00 PM** & **1:00 PM – 3:00 PM**
