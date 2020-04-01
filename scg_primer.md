# SCG Primer

## Other resources 
  - [This Google Doc](https://docs.google.com/document/d/1kTEG6fDjbLhzV7e-ThgpYK3THnoibb9RU57ZLm8EtBs/edit) may also be helpful, but everything looks prettier with Markdown   
  - SCG docs: https://login.scg.stanford.edu/  
  - SCG Slack: susciclu.slack.com  
  
## Directories 
### Home directory (`~/SUNETID`)
Home directory quota is fixed at 32GB. Just about the only thing that should be there is software that you install.  

### Lab directory 
Currently: `/labs/smontgom/`  
After April 3, 2020: `/oak/stanford/groups/smontgom`  
Most of your files should be in `${LAB_DIR}/SUNETID`. The first time you log into SCG, you will have to make your personal directory in `/labs/smontgom/`.  
Shared lab data sets are in `${LAB_DIR}}/shared`. 

### Scratch space  
You can use `/tmp`, but be warned that, like everything else on SCG, nothing is backed up. The hardware for the last scratch space died.  
  
## Login nodes and partitions  
### Login nodes
You start on a login node every time you log in to SCG. Login nodes are the same nodes as the interactive partition, but they still have limited resources until you start a session in the interactive partition. Login nodes are meant for navigating directories, starting `screen`/`tmux` sessions, and other non-intenstive, minor processes (16GB of memory and a restricted number of processes). 

### 


### FREE interactive partition 
Resources available **PER PERSON**: 16 cores, 128GB total for all running interactive jobs


See [these instructions](https://login.scg.stanford.edu/tutorials/data_management/#samba) for how to mount SCG directories locally with Samba.  

See SCG documentation of SLURM basics [here](https://login.scg.stanford.edu/tutorials/job_scripts/). 




Add an alias to always log into the same login node on SCG
Do this on your local computer:
ls ~/.bash*
If you see .bashrc or .bash_profile, add this line to the end of it (doesn’t matter which one if you see both):
alias scg=”ssh <SUNET_ID>@login04.scg.stanford.edu” 
If you copy/paste this line, the quotes won’t be recognized as the right characters. Use nano/vim to edit accordingly 
If need to edit: nano ~/.bash_profile
Then scroll to end of ~/.bash_profile using down arrow
Edit the alias SCG line as needed like fixing or adding the quotes
Save: control+O 
Exit: control+X
The first time you do this, you will need to source ~/.bash_profile for the alias to take effect. Then every time after, Bash will recognize the alias as soon as you start a new Terminal session
Screen sessions and interactive sessions on SCG
screen sessions (or tmux)
start a screen or tmux session before starting any task that takes more than a minute or two or before starting an interactive session. screen sessions will be saved if you log out of SCG. screen sessions are only available in the node in which you launch them (hence the value of adding the above alias to your .bash* file)
handy screen shortcuts:
start a screen session: screen -S <name>
Ctrl + A + D to detach 
screen -ls to list current screen sessions
screen -r <####.name> to reattach to screen session (use full name)
exit within a screen session to end it 
if you get booted from SCG in the middle of a screen session, sometimes it will still say you’re “Attached” to the screen session when you log back in even if you don’t see the processes that were running in your screen session. fix this by “Detach then reattach to screen session”: screen -dr <####.name>
start a FREE interactive session (this acts like running code on durga)
start a screen/tmux session
use “sdev” to start an interactive session: sdev -c 1 -m 10G -t 24:00:00
-c: number of cores
-m: memory. add “M” (Mb) or “G” (Gb) suffix
this is the thing to bump up if you get a core dump or out-of-memory error
-t: time (HH:MM:SS)
default behavior of “sdev” is to request resources from the interactive partition, which requires no billing account
once you’re in an interactive session, you can pretty much treat it like you’re on durga
detaching from and reattaching to the screen session in which you started the interactive session will reconnect you to the interactive session
Per-user limits on interactive sessions: 16 cores and 128 GB of mem
Loading modules in SCG
“module load <module>” is your friend
BEFORE trying to run python:
python2: “module load miniconda/2”
python3: “module load miniconda/3”
BEFORE trying to run R or Rscript:
R v3.6: “module load r/3.6”
R v3.5: “module load r/3.5”
to load outdated modules, like older versions of R, run “module load legacy” first; then, for example, “module load r/3.4”
if you can Google the bioinformatics tool, chances are SCG has already installed the software, and it’s loaded in a module. if you see “command not found”, try loading a module
you can get a (long) list of existing modules with “module avail”; use arrow keys to scroll; “q” to exit
search for modules containing a keyword with “module keyword <keyword>”; use arrow keys to scroll; “q” to exit
how can you find files associated with a module after you load it?
Almost all module add the path to the modules programs/scripts to the PATH variable, so this will show you that entry:
echo $PATH | tr ':' '\n'
SCG OnDemand
SUPER HELPFUL!!
https://ondemand.scg.stanford.edu/pun/sys/dashboard
“Files” tab lets you do file I/O in your home or /labs/smontgom paths
“Interactive Apps” lets you run RStudio, Jupyter Notebooks, and other tools interactively while using SCG file systems and compute resources 
about interactive RStudio
By default, an .rstudio folder is created in your home directory the first time you start an RStudio session. For whatever reason, this can be REALLY slow (something about file I/O in the file system used for home directories). If you start noticing that basic commands in RStudio are being slow, do the following:
kill your sessions
run mv ~/.rstudio ~/.rstudio-backup && ln -s /tmp ~/.rstudio
start a new session. things should be faster now! (the file system that uses /tmp is faster)
SCG Slack susciclu.slack.com
Join the Slack workspace if you use SCG. While it’s not quite as helpful now that John Hanks is gone (sob), you may still get responses from the SCG community if you post a question or error that a Google search didn’t help you answer. It’s also the place to post software installation requests (#software-install-requests channel). 

SLURM basics
SLURM is the job scheduler that SCG uses. Here are a few commands to know:
squeue -u SUNETID gives a list of the jobs currently running under your name (interactive or batch partition. you can use the -p flag to specify, e.g. squeue -u nicolerg -p batch)
sacct (sacct -j JOBID, for example)
Tells you the amount of resources used for recent jobs 
This is particularly important if you are planning to run a large number of jobs on the BILLED batch partition - run one job first, see how many resources it required, and limit the resources you request for your batch of jobs. This is ESPECIALLY important for number of CPUs requested since SCG charges per CPU hour. If you request 2 CPUs but your process only uses 1, you still pay for those 2 CPUs as long as your job runs. SCG charges based on actual CPU time, NOT total time requested (i.e. request as much time as you want, with the knowledge that longer jobs will sit in the queue longer, but be thoughtful with your CPU requests)
eg: sacct -u nicolerg -o JOBID,JobName,MaxRSS,nCPUs,CPUTime --starttime 03/20
Use the -o flag to change the format. e.g.:
MaxRSS: Roughly the memory required (request somewhat more than this)
nCPUs: Number of CPUs requested
CPUTime: Time billed by SCG
see other fields here: https://slurm.schedmd.com/sacct.html 
--starttime: by default, sacct will only show stats for jobs completed since 12:00 AM that day. Extend the time window with this flag (format: MM/DD[/YY]-HH:MM[:SS])
scancel
Kill a job. Use -j JOBID for a single job or -u SUNETID for ALL of your jobs 
Other tips and tricks
echo $SLURM_JOB_ID will tell you if you’re inside a job (yes, you might forget when you get lost in the layers of screen sessions and interactive jobs)
If a running job looks “stuck”, i.e. it’s been actively running much longer than you would expect it to, run scontrol requeue JOBID to “unstick it”. This does NOT restart the job from the beginning
To attach to a node running with srun (to see what processes are running, for example), run srun --jobid JOBID --pty bash -l. This is like SSHing into the node that the job is running on. “Exit” will end that SSH session but not your srun-initiated jobs on that node
Snakemake pipelines
Because of NFS things, I recommend adding a --latency-wait flag to your call. This means the pipeline will wait up to the specified number of seconds for a file to appear before aborting with an error
See this thread in SCG Slack if you would like to keep track of resources for an interactive job 
mount files locally with samba (at least on Mac, not sure about Windows):
1. In terminal: kinit sunetid@stanford.edu
2. Finder Go > Connect to Server > smb://samba.scg.stanford.edu/
3. Select the volumes you want to mount: either homes or lab_smontgom
Done! Find samba under Locations in your Finder. You can now view files, edit scripts in your favorite non-terminal text editor, easily upload/download small files, etc.
