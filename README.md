# Best Practices for Using HPC: Scaling Up to Cluster-Native Workflows

A workshop presentation, practical guide, and Slurm reference designed to help researchers, postdocs, and graduate students transition smoothly from local computing (laptops / Google Colab) to high-performance computing clusters.

Presented by **Recep Erol, PhD** (Computational Scientist for AI, Center for Research Computing, Rice University).

---

## Quick Start: Launching the Presentation

From this directory, run:

```bash
# Display interactive help
make

# Launch the presentation and open in your browser
make slides
```

By default, this serves the presentation on `http://localhost:8000/index.html`. To use another port, pass `PORT`:
```bash
make slides PORT=8080
```

To export the presentation as a high-resolution PDF, run:
```bash
make export-pdf
```
Then navigate to `http://localhost:8000/index.html?print-pdf` in Chrome/Chromium and use the print dialog (`Cmd+P` / `Ctrl+P`) to "Save as PDF" with background graphics enabled.

---

## Directory Overview

```
apps/_hpc/best_practices_for_hpc/
├── index.html                     # Main Reveal.js presentation (16 interactive slides)
├── about_me.html                  # Modular presenter profile card (from VibeCoding-Workshop)
├── Makefile                       # Single-file management (make slides, make check, etc.)
├── README.md                      # Workshop & repository documentation
├── best_practices_HPC.md          # Topic outline & presentation storyboard
├── blog_post_template.md          # Abstract & cluster overview draft
├── blog_post_template_v2.md       # Comprehensive long-form blog post
├── images/
│   └── avatar.jpeg                # Presenter portrait
└── SLURM_scripts/                 # Side-by-side comparison scripts (Anti-Patterns vs Best Practices)
    ├── over_allocation_bad_example.sh      # ❌ The Memory Trap: requesting 128GB for 16GB job
    ├── enough_amount_allocation.sh         # ✅ Right-sizing memory using seff validation
    ├── single_core_job_full_allocate.sh    # ❌ The Sequential Trap: allocating 64 cores for serial runs
    ├── single_core_job_slurm_jobarray.sh   # ✅ Concurrent execution using Slurm Job Arrays
    ├── wasting_gpu_resource.sh             # ❌ The GPU Trap: requesting 4 GPUs for single-device code
    └── correct_gpu_reseource_allocation.sh # ✅ Targeted 1-GPU allocation + Apptainer PyTorch container
```

---

## The 5 Pillars of Cluster-Native Computing

1. **The Mindset Shift**: Shared supercomputers are orchestrated community environments, not bigger personal laptops. Login nodes are strictly gateway access points—computational workloads belong in interactive sessions (`salloc` / OpenOnDemand) or batch jobs (`sbatch`).
2. **Data Logistics & Storage Hygiene**: When to use `rsync` vs `Globus` for multi-TB migrations. Leveraging high-speed scratch (VAST / GPFS) for active I/O while adhering to quota limits and periodic cleanup.
3. **Reproducible Environments**: Packaging dependencies, system libraries, and CUDA runtimes inside Apptainer (Singularity) containers (`.sif`) to ensure identical behavior locally and on the cluster.
4. **Slurm Sizing & The 3 Anti-Patterns**:
   - **The Memory Trap**: Why requesting 128 GB for a 16 GB job causes days of queue delays.
   - **The Sequential Loop Trap**: Replacing serial execution loops with Slurm Job Arrays (`--array=1-100%10`).
   - **The Multi-GPU Hoarding Trap**: Ensuring scripts explicitly utilize multi-GPU distribution (e.g. PyTorch DDP) before requesting multiple accelerators.
5. **Observability & Collaboration**: Auditing efficiency using `seff <jobid>`, monitoring live compute with `nvtop` / `htop`, and engaging with the Center for Research Computing (CRC) during experimental design.

---

## Contact & Collaboration

- **Author**: Recep Erol, PhD
- **Affiliation**: Center for Research Computing (CRC), Rice University
- **Email**: [re51@rice.edu](mailto:re51@rice.edu)
- **LinkedIn**: [linkedin.com/in/erolrecep](https://linkedin.com/in/erolrecep)
- **GitHub**: [github.com/erolrecep](https://github.com/erolrecep)
- **Website**: [erolrecep.github.io](https://erolrecep.github.io)
- **CRC Portal**: [researchcomputing.rice.edu](https://researchcomputing.rice.edu)
