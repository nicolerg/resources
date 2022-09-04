# SCG Primer 
Welcome to SCG! Here is some information that should help you use the SCG Informatics Cluster efficiently. If you are looking to make an account, see [how to request an account](https://login.scg.stanford.edu/accounts/).  

If you would like to contribute information, please add a pull request!  

## Table of Contents
  - [Other resources](#other-resources)
  - [Login nodes](#login-nodes)
  - [Directories](#directories)
      - [Home directory](#home-directory-sunetid)
      - [Lab directory](#lab-directory)
      - [Scratch space](#scratch-space) 
  - [Compute partitions](#compute-partitions)
      - [FREE `interactive` partition](#free-interactive-partition)
      - [BILLED `batch` partition](#billed-batch-partition)
      - [`nih_s10` NIH Supercomputer](#nih_s10-nih-supercomputer)
      - [Job arrays](#job-arrays)
  - [Software modules on SCG](#software-modules-on-scg)
  - [Installing software on SCG](#installing-software-on-scg)
  - [SCG OnDemand](#scg-ondemand)
      - [Interactive RStudio](#interactive-rstudio)
  - [Data access](#data-access)
  - [SLURM basics](#slurm-basics)
  - [Miscellaneous tidbits](#miscellaneous-tidbits)

## Other resources 
  - SCG docs: https://login.scg.stanford.edu/  
  - SCG Slack: http://srcc.slack.com **If you use SCG, I highly recommend joining this Slack Workspace.** You are likely to get responses from SCG employees or other members of the SCG community if you post a question or error that a Google search didn’t help you answer. It’s also the place to post software installation requests (`#scg-software-requests` channel). More information about this workspace can be found [here](https://login.scg.stanford.edu/contact/#scg-slack-workspace).
  
## Login nodes 
You start on a login node every time you log in to SCG. Login nodes are the same nodes as the interactive partition, but they still have limited resources (16GB of memory and a restricted number of processes) until you start a session in the interactive partition. Login nodes are meant for navigating directories, starting `screen`/`tmux` sessions, and other non-intenstive, minor processes. 

Because there are several login nodes and `screen`/`tmux` sessions are only available on the node on which they were initialized, I **highly recommend** adding an alias to your **LOCAL** `~/.bashrc` or `~/.bash_profile` to set a persistent login node (it doesn't matter which one). That way, you will always log into the same login node whenever you connect to SCG, and your `screen`/`tmux` sessions will always be where you expect them. For example:

```bash
# replace SUNETID with *your* SUNET ID 
echo 'alias scg="ssh SUNETID@login04.scg.stanford.edu"' >> ~/.bash_profile
```
There are four login nodes, so adding any ONE of the following statements to `~/.bash_profile` will serve the same purpose as the command above:
```bash
# replace SUNETID with *your* SUNET ID 
# only use ONE of these commands
echo 'alias scg="ssh SUNETID@login01.scg.stanford.edu"' >> ~/.bash_profile
echo 'alias scg="ssh SUNETID@login02.scg.stanford.edu"' >> ~/.bash_profile
echo 'alias scg="ssh SUNETID@login03.scg.stanford.edu"' >> ~/.bash_profile
```

The first time you add this line to your `~/bash*` file, you have to run `source ~/.bash_profile` for the alias to register. After that, the `scg` command will be recognized every time you start Terminal. Then just run `scg` to log in to SCG.  

> Note: `~/.bash_profile` and `~/.bashrc` are only automatically `source`d if your shell is `bash`. If your shell is `zsh`, add this line to `~/.zprofile` instead. If you are not sure which shell you are using, run `echo $SHELL`.  

> Note: Sometimes a single login node is being rebooted, and if that is the node you've specified in your alias above, you will have trouble connecting to SCG using the `scg` command while others do not. In this case, just log in using the standard `ssh SUNETID@login.scg.stanford.edu` to direct you to an available login node (though you will not see any `screen`/`tmux` sessions you started on the other node). When the node is done rebooting, your `scg` command will work again. 

## Directories 
### Home directory (`~/SUNETID`)
Home directory quota is fixed at 32GB. Just about the only thing that should be there is software that you install. 

### Lab directory 
This is either `/labs/[LAB]` or `/oak/stanford/groups/[LAB]` depending on your PI. Most of your files should be in `${LAB_DIR}/SUNETID`. You may have to make this directory yourself when you first join a group on SCG.  

Check the lab quota with `lfs quota -hg scg_lab_[LAB] /oak` OR `lfs quota -hg oak_[LAB] /oak` (for `/labs/[LAB]` and `/oak/stanford/groups/[LAB]`, respectively). 


### Scratch space  
Every node on has SCG (both login and batch) has scratch space mounted at `/tmp`.  This scratch is available only to that node, and the files you create there are visible only to your user.  You have to copy anything you want to save **back to Oak** if you want to be able to access it from other nodes or allow other users to see it.  

There is no quota in this scratch space, but storage is not unlimited.  Files will automatically be deleted when space starts to run out, with the oldest ones being deleted first.  **Do not use `/tmp` for long term storage**.  The main reason to use this is for temporary files you don't care about that may take up a lot of space, and because it is **local**, meaning that any operations you do on files in `/tmp` don't have to go over the network like they do for Oak.  This can lead to a big improvement for some disk intensive operations like alignment and variant/peak calling.

## Compute partitions 

### FREE `interactive` partition 
16 cores, 128GB total are available for all running interactive jobs **PER PERSON**. You can split up those resources any way you would like. Jobs in the interactive partition are limited to 24 hours.  

Launch a process in the `interactive` partition after logging in. There are two ways to do this: 

#### Interactive session
1. Start a `screen`/`tmux` session (you should do this for any process that you expect to take more than a minute in case your connection to SCG is interrupted)  
2. Launch a job in the `interactive` partition
    ```bash 
    sdev -c 1 -m 20 -t 24:00:00
    ```
    - `sdev` is a shortcut for `srun`, which is a SLURM command 
    - `-c`: number of cores
    - `-m`: memory in GB 
    - `-t`: time (format `DD-HH:MM:SS`) 

Once the resources are allocated, you essentially get `ssh`-ed into a new bash session with the requested resources. Then you can start running scripts (almost) just like you would locally on your laptop. 

> Note: Use `srun` instead of `sdev` to bill project (instead of lab) accounts, e.g. `srun -p batch -A prj_[PROJECT] -t 1:00:00 -c 2 --mem-per-cpu=8 --pty /bin/bash`

#### Submit a job to the `interactive` partition with `sbatch` 
If you are running polished code or a standard pipeline that you don't need to worry about debugging, you may prefer to submit a job to the `interactive` job queue using `sbatch`. 

First, write an `sbatch` script, e.g. `test_sbatch.sh`:
```bash 
#!/bin/bash

# See `man sbatch` or https://slurm.schedmd.com/sbatch.html for descriptions
# of sbatch options.
#SBATCH --job-name=test
#SBATCH --cpus-per-task=1
#SBATCH --partition=interactive
#SBATCH --account=default
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=5G

# by default, log files are written to the pwd 

set -e 
module load miniconda/3
python some_python_script.py # this is the process I want to run with the sbatch script 
``` 
Then submit the job using `sbatch test_sbatch.sh`. **It is critical that the `--partition` flag is set to `interactive` if you don't want to get billed.** 

Note that `--cpus-per-task` is equivalent to the number of processes running in parallel.

### BILLED `batch` partition 
The `batch` partition its ideal for parallelizations beyond 16 cores or processes requiring more than 128GB of memory. Billing is done for number of CPUs used * actual run time - SCG does not charge for memory usage (but if you request too much your job might never run).  

Use the `labstats` command to see how much CPU time each lab user has racked up during the billed month.  

Max resource requests on the `batch` partition are 1 TB memory and 48 CPUs. [Memory per CPU is node-specific](https://login.scg.stanford.edu/configuration/).  

You submit jobs to the `batch` partition the same way, with a couple of added flags:  

#### Interactive session ON THE BILLED `batch` PARTITION 
The only reason you would do this is if you are out of resources on the `interactive` partition or you want to run a job with >128GB interactively (unlikely). 
1. Start a `screen`/`tmux` session (you should do this for any process that you expect to take more than a minute in case your connection to SCG is interrupted)  
2. Launch a job in the `batch` partition
    ```bash 
    sdev -c 1 -m 20 -t 24:00:00 -a [LAB_ACCOUNT] -p batch
    ```
    - `sdev` is a shortcut for `srun`, which is a SLURM command 
    - `-c`: number of cores
    - `-m`: memory in GB - bump this up if you get a core dump or out-of-memory error
    - `-t`: time (format `DD-HH:MM:SS`)
    - `-a`: account (not sure what this is? run `scgwhoami` when logged into SCG and look under `Available SLURM Accounts`)
    - `-p`: partition, either `interactive` (default, free) or `batch` (billed; requires `-a`)

> Note: Use `srun` instead of `sdev` to bill project (instead of lab) accounts, e.g. `srun -p batch -A prj_[PROJECT] -t 1:00:00 -c 2 --mem-per-cpu=8 --pty /bin/bash`

#### Submit a job to the BILLED `batch` session with `sbatch` 
If you are running polished code or a standard pipeline that you don't need to worry about debugging, you may prefer to submit a job to the `batch` job queue using `sbatch`. 

First, write an `sbatch` script, e.g. `test_sbatch.sh`:
```bash 
#!/bin/bash

# See `man sbatch` or https://slurm.schedmd.com/sbatch.html for descriptions
# of sbatch options.
#SBATCH --job-name=test
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH --account=[LAB_ACCOUNT]
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=5G

# by default, log files are written to the pwd 

set -e 
module load miniconda/3
python some_python_script.py # this is the process I want to run with the sbatch script 
``` 
Then submit the job using `sbatch test_sbatch.sh`.  

Note that `--cpus-per-task` is equivalent to the number of processes running in parallel.

### `nih_s10` NIH Supercomputer
This system has its own partition. You can run jobs with many CPUs and lots of memory, and it also has Nvidia GPUs for CUDA-accelerated software (typically deep learning or molecular dynamics). While it is free to use, it is very busy so it usually has a long wait time, and it frequently suffers from extended downtime due to hardware instability.
You can read more about it [here](https://login.scg.stanford.edu/uv300/).

### Job arrays
If you need to run a large number of jobs it is possible to use a job array with `sbatch` to automate this: https://slurm.schedmd.com/job_array.html. If you need to do this it is likely to be expensive, so make sure you know what you're doing.

## Software modules on SCG 
`module load <module>` is your friend. If you can Google the bioinformatics tool, chances are SCG has already installed the software, and it’s loaded in a module. if you see `command not found`, try loading a module.  

Some `module` commands:
  - `module avail`: Get a (long) list of existing modules; use arrow keys to scroll; `q` to exit
  - `module keyword <keyword>`: Search for modules containing a keyword; use arrow keys to scroll; `q` to exit 
  - `module unload <module>`: Unload a module 
  - `module purge`: Unload all modules (i.e. revert back to login state)
  - 
**Reproducibility note:** We know that computational reproducibility is very vital for scientific rigor and advancement. Using the same version of software across batches of data and reporting the bioinformatics software version in the manuscript is very important. Make a habit to use `module load <module>/<version>` in your scripts.

*How can you find files associated with a module after you load it?*   
Almost all module add the path to the modules programs/scripts to the `PATH` variable, so this will show you that entry:
`echo $PATH | tr ':' '\n'`

A few of the most critical ones, for example:  
  - BEFORE trying to run `python`:
  ```bash
  module load miniconda/2 #python2
  module load miniconda/3 #python3
  ```
  - BEFORE trying to run `R` or `Rscript`:
  ```bash
  module load r/3.6
  module load r/3.5 
  ```
  - To load outdated modules, like older versions of R, run `module load legacy` first; then, for example, `module load r/3.4`
  
## Installing software on SCG 
Always [check if a module exists](#software-modules-on-scg) before installing software on SCG. If you're really sure you need to install it, there are a few ways to do it:  
- For `R` packages:
    - Load the `r` module corresponding to the version in which you want to install the package (e.g. `module load r/3.6`) 
    - Launch `R` and install packages as usual (e.g. with `install.packages()`). The first time you do this, answer `yes` to let it make a library in your home directory.  
    - Extra tidbit: Use the `.libPaths()` command in `R` to see which paths `R` is looking in to load libraries  
- For `python` modules:  
    - Load the `python` module corresponding to the version in which you want to install the package (e.g. `module load miniconda/3`)  
    - Use `pip install --user MODULE` to install a module locally. Note you will need to load the same module before trying to import this module in the future (e.g. `module load miniconda/3`)  
- For anything else: Install it in your home directory or in a `SOFTWARE` subfolder in your lab directory. 

For particularly tricky installations, or just for anything you think might be useful for anyone else on SCG, add a software installation request to the `#software-install-requests` channel in [SCG's Slack Workspace](https://susciclu.slack.com). I tend to install software myself and also add a request to the channel for anything that's not already installed on SCG.  

Options for more advanced users include Linuxbrew (https://docs.brew.sh/Homebrew-on-Linux), your own Miniconda installation (https://docs.conda.io/en/latest/miniconda.html), and `local::lib` for Perl packages (but really, try to avoid Perl if possible!)

## SCG OnDemand
I <3 [SCG OnDemand](https://ondemand.scg.stanford.edu/pun/sys/dashboard). If off-campus, you must be connected to the [Stanford VPN](https://uit.stanford.edu/service/vpn) to access OnDemand.  
  - `Files` tab lets you do file I/O in your home, lab, or project paths 
  - `Interactive Apps` lets you run RStudio, Jupyter Notebooks, and other tools interactively while using SCG file systems and compute resources 
  
### Interactive RStudio
You can specify the following environmental variables to set the default working directory for RStudio sessions: `RSTUDIO_DATA_HOME` or `RSTUDIO_CONFIG_HOME`.

#### Installing R packages  
It is **not** recommended to install packages within OnDemand's RStudio. Trying to do so will often result in an error (see [here](https://srcc.slack.com/archives/CUY1Q7RQU/p1639576808045100) and [here](https://srcc.slack.com/archives/C8CNSTB88/p1643142536038300) and [here](https://srcc.slack.com/archives/C8CNSTB88/p1659038824687309)).

Instead, log in to SCG in your terminal, load the appropriate version of R, and install the package via the command line. For example, to install `data.table` in R v4.0.3, do the following:
```
ssh SUNETID@login.scg.stanford.edu # or use your alias
module load r/4.0.3
R
> install.packages("data.table")
> q()
exit
```
Then you will be able to load the package in your RStudio session running R v4.0.3 using `library(data.table)`. Note if the library has already been loaded, you will have to restart R before loading the library to load the most updated version. 

## Data access

### Mount SCG locally with `samba`
Mounting files locally means you can directly edit SCG files in a desktop text editor instead of using a command line text editor on SCG. One way to do this is with `samba`. Find platform-specific instructions about how to mount SCG with `samba` [here](https://login.scg.stanford.edu/tutorials/data_movement/#samba). To mount native SCG files (e.g `/labs` or `/projects`), use `smb://samba.scg.stanford.edu/`. If off-campus, you must be connected to the [Stanford VPN](https://uit.stanford.edu/service/vpn) to use `samba`.   

> For Montgomery Lab users: to mount Montgomery Lab Oak storage (e.g. `/oak/stanford/groups/smontgom`), use `smb://oak-smb-smontgom.stanford.edu`  

## SLURM basics
SLURM is the job scheduler that SCG uses. See SCG documentation of SLURM basics [here](https://login.scg.stanford.edu/tutorials/job_scripts/). Here are a few commands to know:

### `squeue`
`squeue -u SUNETID` gives a list of the jobs currently running under your name (`interactive` or `batch` partition. you can use the `-p` flag to specify, e.g. `squeue -u username -p batch`)

### `sacct`
`sacct -j JOBID`, for example, tells you the amount of resources used for recent jobs.  

This is particularly important if you are planning to run a large number of jobs on the BILLED `batch` partition - run one job first, see how many resources it required, and limit the resources you request for your batch of jobs. This is ESPECIALLY important for number of CPUs requested since SCG charges per CPU hour. If you request 2 CPUs but your process only uses 1, you still pay for those 2 CPUs as long as your job runs. SCG charges based on actual CPU time, NOT total time requested (i.e. request as much time as you want, with the knowledge that longer jobs will sit in the queue longer, but be thoughtful with your CPU requests).  

eg: `sacct -u username -o JOBID,JobName,MaxRSS,nCPUs,CPUTime --starttime 03/20`

Use the `-o` flag to change the format. e.g.:
  - `MaxRSS`: Roughly the memory required (request somewhat more than this)
  - `nCPUs`: Number of CPUs requested
  - `CPUTime`: Time billed by SCG

Use the `--starttime` flag to change the time range in which to show job stats. By default, `sacct` will only show stats for jobs completed since 12:00 AM that day. Extend the time window with this flag (format: `MM/DD[/YY]-HH:MM[:SS]`).  

See other fields here: https://slurm.schedmd.com/sacct.html   

### `seff`
`seff JOBID` provides a nice summary of a completed job, e.g. resources used and state (completed, failed, out of memory, etc.). I now find this more useful than `sacct`.

### `scancel`
Kill a job. Use `-j JOBID` for a single job or `-u SUNETID` for **ALL** of your jobs. 

### Other SLURM tips and tricks
  - `echo $SLURM_JOB_ID` will tell you if you’re inside a job (yes, you might forget when you get lost in the layers of screen sessions and interactive jobs)
  - If a running job looks “stuck”, i.e. it’s been actively running much longer than you would expect it to, `ssh` into the node it's running on and `htop` to see if it looks active. If there are processes running but with very low CPU usage, something may have gone wrong. Run `scontrol requeue JOBID` to kill and resubmit the job to the queue
  - To attach to a node running with `srun` (to see what processes are running, for example), run `srun --jobid JOBID --pty bash -l`. This is like SSHing into the node that the job is running on. `exit` will end that SSH session but not your srun-initiated jobs on that node. (Alternatively, you can actually just `ssh` into the node displayed from `squeue`.) 

## Miscellaneous tidbits 
  - Because of NFS things, I recommend adding a `--latency-wait` flag to your calls to `snakemake` pipelines. This means the pipeline will wait up to the specified number of seconds for a file to appear before aborting with an error. 
  - See [this thread](https://susciclu.slack.com/archives/C8CNSTB88/p1550866979024200) in SCG Slack if you would like to keep track of resources for an interactive job. 
  - See [these instructions](https://login.scg.stanford.edu/tutorials/data_management/#samba) for how to mount SCG directories locally with Samba.  
  - Globus is another option for transferring files (https://www.globus.org) - it does not require 2-factor authentication! As of April 2020, Globus can now be used for some of the cloud. See [this announcement](https://srcc.slack.com/archives/C8CSZF7DX/p1651006934170209) for details.  
  - rclone (https://rclone.org) makes it possible to transfer data from SCG to Box (PHI approved!), Google Drive, Dropbox, Google Cloud etc. See [this tutorial](https://github.com/nicolerg/resources/blob/master/rclone_box.md) for more info.
  - SCG is **NOT** PHI-approved. 
