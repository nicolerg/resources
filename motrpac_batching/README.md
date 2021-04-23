# MoTrPAC clinical sample batching 

Use `randomization.R` to make well-balanced batches of MoTrPAC human samples in terms of clinical site, intervention group, age, and sex.  

### Inputs  
- Shipment manifest Excel file(s) from the Biorepository, e.g. `Stanford_ADU830-10060_120720.xlsx`  
- Corresponding CSV file(s) from the Biospecimen Metadata Download API on [motrpac.org](https://www.motrpac.org/), e.g. `ADU830-10060.csv`  

### Outputs  
- Two files per assay & tissue combination:  
  - Blinded batch assignments in the format `precovid_[SAMPLE_TYPE]-samples_BLINDED-batch-assignments.csv` (see example [here](examples/precovid_4-samples_BLINDED-batch-assignments.csv))  
  - Unblinded batching metadata in the format `precovid_[SAMPLE_TYPE]-samples_UNBLINDED-batch-characteristics.csv`  
- Summary of batch characteristics (`stdout`) (see example [here](examples/out.log))  

### Usage 

#### Required R packages
```txt
data.table
readxl
testit
argparse
```

#### Parameters
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
                        Path to output directory
  -n MAX_N_PER_BATCH, --max-n-per-batch MAX_N_PER_BATCH
                        Max number of samples per batch
```

#### Example commands 
Here is an example of how to run the script, assuming the shipment manifest Excel files and API metadata CSV files are in the same directory as this script. Include manifests and metadata for *all* pre-COVID clinical samples, i.e. both adult and pediatric shipments.  
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
