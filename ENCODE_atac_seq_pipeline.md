# Additional documentation for ENCODE ATAC-Seq QC and Analysis Pipeline 

This documentation applies to v1.7.0 of the [ENCODE ATAC-seq pipeline](https://github.com/ENCODE-DCC/atac-seq-pipeline). **This documentation has not been verified or approved by ENCODE. It's for personal reference.**  

### Important references:
- GitHub repository for the ENCODE ATAC-seq pipeline: https://github.com/ENCODE-DCC/atac-seq-pipeline
- ENCODE ATAC-seq pipeline documentation: https://www.encodeproject.org/atac-seq/
- ENCODE data quality standards: https://www.encodeproject.org/atac-seq/#standards 
- ENCODE terms and definitions: https://www.encodeproject.org/data-standards/terms/

### Table of Contents:
    
1. [Install and test ENCODE ATAC-seq pipeline and dependencies](#1-install-and-test-encode-atac-seq-pipeline-and-dependencies)

    1.1 Clone the ENCODE repository

    1.2 Install the `Conda` environment with all software dependencies

    1.3 Initialize `Caper`

    1.4 Run a test sample 
    
    1.5 Install genome databases

2. [Run the ENCODE ATAC-seq pipeline](#2-run-the-encode-atac-seq-pipeline)
    
    2.1 Generate configuration files  
    
    2.2 Run the pipeline
    
3. [Organize outputs](#3-organize-outputs)

    3.1 Collect important outputs with `Croo`
    
    3.2 Generate a spreadsheet of QC metrics for all samples with `qc2tsv`


## 1. Install and test ENCODE ATAC-seq pipeline and dependencies 
All steps in this section must only be performed once. After dependencies are installed and genome databases are built, skip to [here](#3-run-the-encode-atac-seq-pipeline).

The ENCODE pipeline supports many cloud platforms and cluster engines. It also supports `docker`, `singularity`, and `Conda` to resolve complicated software dependencies for the pipeline. There are special instructions for two major Stanford HPC servers (SCG4 and Sherlock).  

This documentation is tailored for users who use non-cloud computing environments, including clusters and personal computers. Therefore, this documentation describes the `Conda` implementation. Refer to ENCODE's documentation for alternatives. 

### 1.1 Clone the ENCODE repository
Clone the v1.7.0 ENCODE repository and this repository in a folder in your home directory:
```bash
cd ~/ATAC_PIPELINE
git clone --single-branch --branch v1.7.0 https://github.com/ENCODE-DCC/atac-seq-pipeline.git
```

### 1.2 Install the `Conda` environment with all software dependencies  
Install `conda` by following [these instructions](https://github.com/ENCODE-DCC/atac-seq-pipeline/blob/master/docs/install_conda.md). Perform Step 5 in a `screen` or `tmux` session, as it can take some time.   

### 1.3 Initialize `Caper`
Installing the `Conda` environment also installs `Caper`. Make sure it works:
```bash
conda activate encode-atac-seq-pipeline
caper
```
If you see an error like `caper: command not found`, then add the following line to the bottom of ~/.bashrc and re-login.
```
export PATH=$PATH:~/.local/bin
```

Choose a platform from the following table and initialize `Caper`. This will create a default `Caper` configuration file `~/.caper/default.conf`, which have only required parameters for each platform. There are special platforms for Stanford Sherlock/SCG users.
```bash
$ caper init [PLATFORM]
```

**Platform**|**Description**
:--------|:-----
sherlock | Stanford Sherlock cluster (SLURM)
scg | Stanford SCG cluster (SLURM)
gcp | Google Cloud Platform
aws | Amazon Web Service
local | General local computer
sge | HPC with Sun GridEngine cluster engine
pbs | HPC with PBS cluster engine
slurm | HPC with SLURM cluster engine

Edit `~/.caper/default.conf` according to your chosen platform. Find instruction for each item in the following table.
> **IMPORTANT**: ONCE YOU HAVE INITIALIZED THE CONFIGURATION FILE `~/.caper/default.conf` WITH YOUR CHOSEN PLATFORM, THEN IT WILL HAVE ONLY REQUIRED PARAMETERS FOR THE CHOSEN PLATFORM. DO NOT LEAVE ANY PARAMETERS UNDEFINED OR CAPER WILL NOT WORK CORRECTLY.

**Parameter**|**Description**
:--------|:-----
tmp-dir | **IMPORTANT**: A directory to store all cached files for inter-storage file transfer. DO NOT USE `/tmp`.
slurm-partition | SLURM partition. Define only if required by a cluster. You must define it for Stanford Sherlock.
slurm-account | SLURM partition. Define only if required by a cluster. You must define it for Stanford SCG.
sge-pe | Parallel environment of SGE. Find one with `$ qconf -spl` or ask you admin to add one if not exists.
aws-batch-arn | ARN for AWS Batch.
aws-region | AWS region (e.g. us-west-1)
out-s3-bucket | Output bucket path for AWS. This should start with `s3://`.
gcp-prj | Google Cloud Platform Project
out-gcs-bucket | Output bucket path for Google Cloud Platform. This should start with `gs://`.  

An important optional parameter is `db`. If you would like to enable call-catching (i.e. re-use ouputs from previous workflows, which is particularly useful if a workflow fails halfway through a pipeline), add the following lines to `~/.caper/default.conf`:  
```
db=file
java-heap-run=4G
```

### 1.4 Run a test sample 
Follow [these platform-specific instructions](https://github.com/ENCODE-DCC/caper/blob/master/README.md#activating-conda-environment) to run a test sample. Use the following variable assignments:
```bash
PIPELINE_CONDA_ENV=encode-atac-seq-pipeline
WDL=~/ATAC_PIPELINE/atac-seq-pipeline/atac.wdl
INPUT_JSON=https://storage.googleapis.com/encode-pipeline-test-samples/encode-atac-seq-pipeline/ENCSR356KRQ_subsampled_caper.json
```  
Note that `Caper` writes all outputs to the current working directory, so first `cd` to the desired output directory before using `caper run` or `caper server`.   

Here is an example of how the test workflow is run on Stanford SCG (SLURM):  
```
conda activate ${PIPELINE_CONDA_ENV}
JOB_NAME=encode_test
sbatch -A ${ACCOUNT} -J ${JOB_NAME} --export=ALL --mem 2G -t 4-0 --wrap "caper run ${WDL} -i ${INPUT_JSON}"
```

### 1.5 Install genome databases

Choose a genome from `hg19`, `hg38`, `mm9`, or `mm10`. Here we use `hg38` as an example. You are also able to [install custom genome databases](https://github.com/ENCODE-DCC/atac-seq-pipeline/blob/master/docs/build_genome_database.md#how-to-build-genome-database-for-your-own-genome) outside of those provided by ENCODE.  

Specify a destination directory and install the ENCODE hg38 reference with the following command. We recommend not to run this installer on a login node of your cluster. It will take >8GB memory and >2h time.   
```bash  
conda activate encode-atac-seq-pipeline
outdir=/path/to/reference/genome/hg38
bash ~/ATAC_PIPELINE/atac-seq-pipeline/scripts/download_genome_data.sh hg38 ${outdir}  
```
    
## 2. Run the ENCODE ATAC-seq pipeline  
Running the pipeline with replicates outputs all of the same per-sample information generated by running the pipeline with a single sample but improves power for peak calling and outputs a higher-confidence peak set called using all replicates. Master peak sets are generated for each workflow (i.e. set of replicates or singleton).  

### 2.1 Generate configuration files
A configuration (config) file in JSON format that specifies input parameters is required to run the pipeline. Find comprehensive documentation of definable parameters [here](https://github.com/ENCODE-DCC/atac-seq-pipeline/blob/master/docs/input.md).  

### 2.2 Run the pipeline 
Actually running the pipeline is straightforward. However, the command is different depending on the environment in which you set up the pipeline. Refer back to environment-specific instructions [here](https://github.com/ENCODE-DCC/caper/blob/master/README.md#activating-conda-environment).

An `atac` directory containing all of the pipeline outputs is created in the output directory (note the default output directory is the current working directory). One arbitrarily-named subdirectory for each config file (assuming the command is run in a loop for several samples) is written in `atac`.  

Here is an example of code that submits a batch of pipelines to the Stanford SCG job queue. `${JSON_DIR}` is the path to a batch of config files with names `{WORKFLOW_ID}.json`:  
```bash
conda activate encode-atac-seq-pipeline

ATACSRC=~/ATAC_PIPELINE/atac-seq-pipeline
OUTDIR=/path/to/output/directory
cd ${OUTDIR}

for json in $(ls ${JSON_DIR}); do 
  
  INPUT_JSON=${JSON_DIR}/${json}
  JOB_NAME=$(basename ${INPUT_JSON} | sed "s/\.json.*//")

  sbatch -A ${ACCOUNT} -J ${JOB_NAME} --export=ALL --mem 2G -t 4-0 --wrap "caper run ${ATACSRC}/atac.wdl -i ${INPUT_JSON}"
done
```

## 3. Organize outputs

### 3.1 Collect important outputs with `Croo`
`Croo` is a tool ENCODE developed to simplify the pipeline outputs. It was installed along with the `Conda` environment. Run it on each sample in the batch. See **Table 3.1** for a description of outputs generated by this process. 
```
conda activate encode-atac-seq-pipeline

cd ${OUTDIR}/atac
for dir in *; do 
  cd $dir
  croo metadata.json 
  cd ..
done
```
    
**Table 3.1.** Important files in `Croo`-organized ENCODE ATAC-seq pipeline output.  

| Subdirectory or file                      | Description                             |
|-------------------------------------------|-----------------------------------------|
| `qc/*` | Components of the merged QC spreadhseet (see Step 4.2) | 
| `signal/*/*fc.signal.bigwig` | MACS2 peak-calling signal (fold-change), useful for visualizing "read pileups" in a genome browser |
| `signal/*/*pval.signal.bigwig` | MACS2 peak-calling signal (P-value), useful for visualizing "read pileups" in a genome browser. P-value track is more dramatic than the fold-change track |
| `align/*/*.trim.merged.bam` | Unfiltered BAM files |
| `align/*/*.trim.merged.nodup.no_chrM_MT.bam` | Filtered BAM files, used as input for peak calling |
| `align/*/*.tagAlign.gz` | [tagAlign](https://genome.ucsc.edu/FAQ/FAQformat.html#format15) files from filtered BAMs |
| `peak/overlap_reproducibility/ overlap.optimal_peak.narrowPeak.hammock.gz` | Hammock file of `overlap` peaks, optimized for viewing peaks in a genome browser |
| `peak/overlap_reproducibility/ overlap.optimal_peak.narrowPeak.gz` | BED file of `overlap` peaks. **Generally, use this as your final peak set** |
| `peak/overlap_reproducibility/ overlap.optimal_peak.narrowPeak.bb` | [bigBed](https://genome.ucsc.edu/goldenPath/help/bigBed.html) file of `overlap` peaks  useful for visualizing peaks in a genome browser |
| `peak/idr_reproducibility/ idr.optimal_peak.narrowPeak.gz` | `IDR` peaks. More conservative than `overlap` peaks |

[ENCODE recommends](https://www.encodeproject.org/atac-seq/) using the `overlap` peak sets when one prefers a low false negative rate but potentially higher false positives; they recommend using the `IDR` peaks when one prefers low false positive rates.
    
### 3.2 Generate a spreadsheet of QC metrics for all samples with `qc2tsv`
This is most useful if you ran the pipeline for multiple samples. **Step 3.1** generates a `qc/qc.json` file for each pipeline run. After installing `qc2tsv` within the `encode-atac-seq-pipeline` `Conda` environment (`pip install qc2tsv`), run the following command to compile a spreadsheet with QC from all samples: 
```
cd ${outdir}/atac
qc2tsv $(find -path "*/qc/qc.json") --collapse-header > spreadsheet.tsv
```

**Table 3.2** provides definitions for a limited number of metrics included in the JSON QC reports. The full JSON report includes >100 metrics per sample; some lines are duplicates, and many metrics are irrelevant for running the pipeline with a single biological replicate. 

**Table 3.2. Description of relevant QC metrics.**

| Metric | Definition/Notes |
|--------|------------------|
| replication.reproducibility.overlap.N_opt | Number of optimal overlap_reproducibility peaks |
| replication.reproducibility.overlap.opt_set | Peak set corresponding to optimal overlap_reproducibility peaks |
| replication.reproducibility.idr.N_opt | Number of optimal idr_reproducibility peaks | 
| replication.reproducibility.idr.opt_set | Peak set corresponding to optimal idr_reproducibility peaks |
| replication.num_peaks.num_peaks | Number of peaks called in each replicate | 
| peak_enrich.frac_reads_in_peaks.macs2.frip | Replicate-level FRiP in raw MACS2 peaks | 
| peak_enrich.frac_reads_in_peaks.overlap.{opt_set}.frip | Many FRiP values are reported. In order to get the FRiP corresponding to the overlap_reproducibility peak set, you need to cross-reference the `replication.reproducibility.overlap.opt_set` metric with these column names to extract the appropriate FRiP. For example, if `replication.reproducibility.overlap.opt_set` is `pooled-pr1_vs_pooled-pr2`, then you need to extract the FRiP value from the `peak_enrich.frac_reads_in_peaks.overlap.pooled-pr1_vs_pooled-pr2.frip` column. See **insert script name** to see how to do this in an automated way |
| peak_enrich.frac_reads_in_peaks.idr.{opt_set}.frip | Cross-reference with `replication.reproducibility.idr.opt_set`. See `peak_enrich.frac_reads_in_peaks.overlap.{opt_set}.frip` |
| align.samstat.total_reads | Total number of alignments* (including multimappers)|
| align.samstat.pct_mapped_reads | Percent of reads that mapped|
| align.samstat.pct_properly_paired_reads |Percent of reads that are properly paired|
| align.dup.pct_duplicate_reads |Fraction (not percent) of read pairs that are duplicates **after** filtering alignments for quality|
| align.frac_mito.frac_mito_reads | Fraction of reads that align to chrM **after** filtering alignments for quality and removing duplicates | 
| align.nodup_samstat.total_reads | Number of alignments* after applying all filters |
| align.frag_len_stat.frac_reads_in_nfr | Fraction of reads in nucleosome-free-region. Should be a value greater than 0.4 |
| align.frag_len_stat.nfr_over_mono_nuc_reads | Reads in nucleosome-free-region versus reads in mononucleosomal peak. Should be a value greater than 2.5 |
| align.frag_len_stat.nfr_peak_exists | Does a nucleosome-free-peak exist? Should be `true` |
| align.frag_len_stat.mono_nuc_peak_exists | Does a mononucleosomal-peak exist? Should be `true` |
| align.frag_len_stat.di_nuc_peak_exists | Does a dinucleosomal-peak exist? Ideally `true`, but not condemnable if `false` |
| lib_complexity.lib_complexity.NRF | Non-reduandant fraction. Measure of library complexity, i.e. degree of duplicates. Ideally >0.9 |
| lib_complexity.lib_complexity.PBC1 | PCR bottlenecking coefficient 1. Measure of library complexity. Ideally >0.9 |
| lib_complexity.lib_complexity.PBC2 | PCR bottlenecking coefficient 2. Measure of library complexity. Ideally >3 |
| align_enrich.tss_enrich.tss_enrich | TSS enrichment |

*Note: Alignments are per read, so for PE reads, there are two alignments per fragment if each PE read aligns once. 
