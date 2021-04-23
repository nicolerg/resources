# MoTrPAC clinical sample batching 

Use [`randomization.R`](randomization.R) to make well-balanced batches of MoTrPAC human samples in terms of clinical site, intervention group, age, and sex. 

### Inputs  
- Shipment manifest Excel file(s) from the Biorepository, e.g. `Stanford_ADU830-10060_120720.xlsx`  
- Corresponding CSV file(s) from the Biospecimen Metadata Download API on [motrpac.org](https://www.motrpac.org/), e.g. `ADU830-10060.csv`   

> IMPORTANT: Include manifests for both adult *and* pediatric samples to randomize studies together.  

> IMPORTANT: If the manifests include multiple aliquots of the same samples for different assays, you **MUST** add an `assay` column to *either* of these input files to distiguish the different sets of aliquots. For example, if muscle samples are being processed for both ATAC-seq and RNA-seq at Stanford, add an `assay` column with the values `rnaseq` and `atacseq`. The values themselves do not matter as long as they separate the sets of aliquots.  

### Outputs  
- Two files per assay & tissue combination:  
  - Blinded batch assignments in the format `precovid_[SAMPLE_TYPE]-samples_BLINDED-batch-assignments.csv` (see example [here](examples/precovid_4-samples_BLINDED-batch-assignments.csv))  
  - Unblinded batching metadata in the format `precovid_[SAMPLE_TYPE]-samples_UNBLINDED-batch-characteristics.csv`  
- Summary of batch characteristics (`stdout`) (see example [here](examples/out.log))  

### Methodology  
1. Merge all shipment manifests and metadata files  
2. Define sample groups for batching (sample type code, and assay if applicable)  
3. For each sample group:  
  i. Predefine the number and max size of batches  
  ii. Identify the number of samples associated with each participant ID (pid) in the sample group, "N"  
  iii. For each pid, define the "group" as the combination of clinical site (`codedsiteid`) and intervention (`randomgroupcode`)  
  iv. Order pids by "N" then "group", largest to smallest    
  v. Iterate through the ordered rows of pids, starting with individuals with the largest number of corresponding samples, and interatively assign pids to consecutive batches, ensuring that the max batch size is not exceeded  
  vi. Print batch composition to `stdout`  
  vii. Output shipment positions and batch assignments to file  

### Usage 

#### Required R packages
```txt
data.table
readxl
testit
argparse
```

#### Example commands 
Here is an example of how to run the script from the command line, assuming the shipment manifest Excel files and API metadata CSV files are in the same directory as this script. Include manifests and metadata for *all* pre-COVID clinical samples, i.e. both adult and pediatric shipments.  
```bash
Rscript randomization.R \
    --shipment-manifest-excel Stanford_ADU830-10060_120720.xlsx Stanford_PED830-10062_120720.xlsx \
    --api-metadata-csv ADU830-10060.csv PED830-10062.csv \
    --outdir ../batches 
```  
Equivalently:  

```bash
Rscript randomization.R \
    -s Stanford_ADU830-10060_120720.xlsx Stanford_PED830-10062_120720.xlsx \
    -a ADU830-10060.csv PED830-10062.csv \
    -o ../batches 
```  
A summary of batching statistics is printed to the console. To save all output to a log file for later reference, add ` > out.log 2>&1` to the end of the command, e.g.: 
```bash
Rscript randomization.R \
    -s Stanford_ADU830-10060_120720.xlsx Stanford_PED830-10062_120720.xlsx \
    -a ADU830-10060.csv PED830-10062.csv \
    -o ../batches > ../batches/out.log 2>&1
```
See an example of this log file [here](examples/out.log). 

Alternatively, run the script interactively in RStudio by commenting out lines 13-26 and manually defining arguments on lines 28-31.  

### Argument documentation
Run `Rscript randomization.R -h` to see a help message similar to this one:  
```bash
usage: Rscript randomization.R [-h]
                               [-s SHIPMENT_MANIFEST_EXCEL [SHIPMENT_MANIFEST_EXCEL ...]]
                               [-a API_METADATA_CSV [API_METADATA_CSV ...]]
                               [-o OUTDIR] 
                               [-n MAX_N_PER_BATCH]
required arguments: 
  -s SHIPMENT_MANIFEST_EXCEL [SHIPMENT_MANIFEST_EXCEL ...], --shipment-manifest-excel SHIPMENT_MANIFEST_EXCEL [SHIPMENT_MANIFEST_EXCEL ...]
                        Path(s) to shipment manifest Excel files, e.g.
                        Stanford_ADU830-10060_120720.xlsx
                        Stanford_PED830-10062_120720.xlsx
  -a API_METADATA_CSV [API_METADATA_CSV ...], --api-metadata-csv API_METADATA_CSV [API_METADATA_CSV ...]
                        Path(s) to sample metadata from web API, e.g.
                        ADU830-10060.csv PED830-10062.csv
optional arguments:
  -h, --help            show help message and exit
  -o OUTDIR, --outdir OUTDIR
                        Path to output directory. Default: "."
  -n MAX_N_PER_BATCH, --max-n-per-batch MAX_N_PER_BATCH
                        Max number of samples per batch. Default: 94 
```

### Help
For questions about the documentation or any issues with the code, please email Nicole at nicolerg@stanford.edu.   
