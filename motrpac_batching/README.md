# MoTrPAC clinical sample batching 

#TODO

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
