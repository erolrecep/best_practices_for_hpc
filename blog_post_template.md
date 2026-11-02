# Workshop Abstract / Blog Post Template
Unlocking the full potential of advanced computing requires moving beyond the mindset of simply scaling up local code. While transitioning from a personal desktop to a shared High-Performance Computing (HPC) environment like Rice University's RANGE cluster removes local bottlenecks, true efficiency comes from mastering cluster-native workflows. RANGE is a next-generation NVIDIA GPU cluster designed to accelerate AI and data-driven research, featuring cutting-edge H100 and H200 GPUs interconnected with ultra-fast NDR networking [cite: 1.1.1]. 

However, navigating these powerful resources requires adaptation.
This workshop provides a practical guide to best practices on the RANGE cluster, addressing the most common operational challenges researchers face. Participants will explore how to move beyond single-threaded, sequential executions to leverage the full power of parallel, distributed, and GPU-accelerated computing. Rather than running experiments one-by-one, attendees will learn how to structure batch arrays and concurrent workloads to dramatically shorten time-to-discovery.
We will cover essential strategies for high-impact cluster usage, including:

 - High-Performance Data Transfer: Safely migrating large datasets between external institutions and RANGE's VAST-based high-performance scratch space [cite: 1.1.1] using tools like rsync and Globus.
 - Resource Optimization: Avoiding common pitfalls like over-allocating memory (e.g., requesting 128 GB for 16 GB workloads) or under-utilizing GPU allocations (e.g., locking 4 GPUs while active code only targets 1).
 - Reproducible Scientific Environments: Packaging dependencies and workflows with container technologies (Apptainer/Singularity) to ensure seamless execution.
 - Expert Consultation: Effectively collaborating with the Center for Research Computing (CRC) team to optimize and tailor your pipelines.
 - Whether performing high-fidelity simulations, distributed machine learning, or complex data processing, this session equips you with the tools to write efficient, reproducible HPC workflows.

