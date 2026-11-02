# Best Practices of Using HPC

---

* Title Page

---

* About Me - Recep Erol, PhD

---

* Agenda

---

* Use Cases for HPC
\_ HPC for everyone --> Shared resource environment. Mindful on your decisions
\_ HPC for Automated Job running. It's not an environment for development!
\_ HPC for Parallel computing tasks environment. Not for single-task
\_ HPC for Distributed Computing tasks. --> Requires training but shortens the compute time

---

* Scalability: Move your computation from PC/Laptop to HPC
\_ Be prepared to run the job on your laptop with multi-core or hardware accelerated setup
\_ Start small and increase gradually! The purpose is running compute tasks in shorter time and optimized fashion
\_ 

---

* Using Storage Efficiently 
\_ You don't need to write everything to disk. Job may produce a lot of data, keep only the important one
\_ Frequently check your storage and if the data is not needed, please backup them somewhere else.
\_ 

---

* Accessing HPC via SSH & Accessing HPC via OpenOnDemand
\_ SSH connection is a great way to communicate with HPC. Be aware that login nodes are not place for running any software remotely i.e VSCode, Codex, or Copilot.
\_ OpenOnDemand have some applications to run Jupyter Notebook, Matlab, and so on.
\_ 

---

* Building Scientific Workflow: Determine Entities and Duck-Type them on HPC
\_ Scientific computing is a long run work. You always add and remove pieces of it. While doing all these things, reproducibility, and maintainability should be doable on all these stages of the workflow management.
\_ Test on your PC and make sure the same setup is configured on HPC environment as well.
\_ Use management tools for automation including Makefile or CMakefile

---

* Resource Allocation: How Much This Needed?
\_ This is the heart of the HPC.
\_ In the first few runs, difficult to estimate the optimal amount of resources to run. You should train yourself on this.
\_ Your code should say that the allocated resources will be utilized at most!
\_ This thing is now limited with resource, it's also important not to keep the resources occupied if you're not using at all. HPC is for everyone!

---

* Data Transfer: Local to HPC or Remote to HPC
\_ Data transfer is an important aspect on HPC. Consolidate with CRC team for how and what kind of data can be transfered or used in HPC environment
\_ HPC is not for personal data storage!
\_ HPC is not for lab data storage!
\_ 

---

* Building Folder Setup for Job Submission and Outputs
\_ History of job submissions and their behavior would easily help you to make better decisions for later ones.
\_ Job outputs are also important. Keep track of them and make sure the SLURM job submitted gives the expected output.
\_ The overall reason of having a dedicated folder to keep submitted job script and output in the same folder.

---

* Monitoring and Configuring Compute: Practices for Debugging and Profiling
\_ As we discussed on previous slides, both of them debugging and profiling should be done on your PC first to make sure the planned steps are happening as planned.
\_ Profiling is a great way to understand how your code is running on the hardware.
	+ resource consumption
	+ timing of algorithm steps
	+ Identify milestones including data write, bottlenecks, or other steps like process operations.

---

* About Me - Recep Erol, PhD

---

* Title Page

---