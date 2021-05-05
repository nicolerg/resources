#!/bin/R
# Nicole Gay
# 22 April 2021
# batching for MoTrPAC clinical samples

library(data.table)
library(readxl)
library(testit)
library(argparse)

### if you want to run this code in RStudio instead of from the command line, 
### comment out this chunk and uncomment/define the variables listed underneath
parser = ArgumentParser()
parser$add_argument("-s", "--shipment-manifest-excel", type="character", nargs="+",
                    help="Path(s) to shipment manifest Excel files, e.g. Stanford_ADU830-10060_120720.xlsx Stanford_PED830-10062_120720.xlsx")
parser$add_argument("-a", "--api-metadata-csv", type="character", nargs="+",
                    help="Path(s) to sample metadata from web API, e.g. ADU830-10060.csv PED830-10062.csv")
parser$add_argument("-o", "--outdir", type="character", default=".",
                    help="Path to output directory")
parser$add_argument("-n", "--max-n-per-batch", type="integer", default=94,
                    help="Max number of samples per batch")
args = parser$parse_args()
shipments = args$shipment_manifest_excel
apis = args$api_metadata_csv
outdir = args$outdir
max_n_per_batch = args$max_n_per_batch
###
# shipments = c("file1.xlsx", "file2.xlsx")
# apis = c("file1.csv", "file2.csv")
# outdir = "."
# max_n_per_batch = 94

# check formats
if(length(shipments) == 0){
  stop("Required argument '--shipment-manifest-excel' is empty. Please provide at least one path.")
}
if(length(apis) == 0){
  stop("Required argument '--api-metadata-csv' is empty. Please provide at least one path.")
}
if(!all(sapply(shipments, function(x) grepl("\\.xls", x, ignore.case=T)))){
  stop(sprintf("Shipment manifests are not in the expected .xls or .xlsx format: %s", paste(shipments, collapse=', ')))
}
if(!all(sapply(apis, function(x) grepl("\\.csv$", x, ignore.case = T)))){
  stop(sprintf("API metadata files are not in the expected .csv format: %s", paste(apis, collapse=', ')))
}

# read in shipment manifests
# error reading in Excel file because "Box" is a mix of numeric and string. fix that
read_shipment = function(path){
  # read first line
  trunc = read_excel(path, n_max=2)
  which(colnames(trunc)=='Box')
  types = rep("guess", ncol(trunc))
  types[which(colnames(trunc)=='Box')] = 'text'
  # make sure "Box" is read in as character
  full = data.table(read_excel(path, col_types = types))
  return(full)
}
ship_list = list()
for (s in shipments){
  ship_list[[s]] = read_shipment(s)
}
ship = rbindlist(ship_list, fill=T)

# read in API metadata 
api_list = list()
for (a in apis){
  api_list[[a]] = fread(a, sep=',', header=T)
}
api = rbindlist(api_list, fill=T)

# make colnames lowercase for simplicity
colnames(ship) = tolower(colnames(ship))
colnames(api) = tolower(colnames(api))

# merge
api[,viallabel := as.character(viallabel)]
ship[,viallabel := as.character(viallabel)]
ship[,`2d barcode` := as.character(`2d barcode`)]
# PBMCs don't have barcodes?
all_meta = merge(api, ship, by='viallabel')
assert(nrow(all_meta) == nrow(ship))
all_meta[all_meta=='.'] = NA
               
if(nrow(all_meta)!=nrow(api)){
  warning(sprintf("The number of samples in the merged metadata (%s) is not the same as the number of samples in the biospecimen metadata '%s' (%s). Check for a merging error.\n",
          nrow(all_meta),
          paste0(basename(apis), collapse=', '),
          nrow(api)))
}

# subset to existing samples
all_meta = all_meta[!(is.na(viallabel) | is.na(box))]

# "study" is redundant with "randomgroupcode"
# there can be multiple bid per pid. pid id human participant id. use pid as identifier
# visitcode = baseline versus post. ignore this because all samples from an individual will be together

if("assay" %in% colnames(all_meta)){
  all_meta = all_meta[,.(viallabel, pid, protocol, codedsiteid, barcode, 
                         sampletypecode, randomgroupcode, sex_psca, calculatedage, 
                         box, position, assay)]
}else{
  all_meta = all_meta[,.(viallabel, pid, protocol, codedsiteid, barcode, 
                         sampletypecode, randomgroupcode, sex_psca, calculatedage, 
                         box, position)]
}

# columns with 0 variance
remove = c()
for(c in colnames(all_meta)){
  if(length(unique(all_meta[,get(c)]))==1){
    remove = c(remove, c)
  }
}
message(sprintf("These columns have 0 variance in the merged metadata: %s\n",
                paste0(remove, collapse=', ')))
# all_meta[,(remove) := NULL]

#table(all_meta[,sampletypecode], all_meta[,randomgroupcode])
# 4 = PaxGene RNA
# 5 = PBMC
# 6 = Muscle

# randomize batches for each assay & tissue
# we want to randomize on site, randomgroupcode (which includes ped vs adult), sex, calculatedage 
# all samples of a pid will stay together 
# randomization will be independently performed in each tissue
if(!"assay" %in% colnames(all_meta)){
  warning("'assay' is not in the column names of the merged API and shipment metadata. Batching will assume that all samples from a given tissue are for a single assay.\n")
  all_meta[,batching_group := sampletypecode]
}else{
  all_meta[,batching_group := paste0(assay, '_', sampletypecode)]
}

make_batches = function(nplates, curr_batch_pid, b){
  
  # assign group, checking total size 
  batch_sizes = rep(0, nplates) 
  names(batch_sizes) = 1:nplates
  batch_iter = 1
  curr_batch_pid[,batch := NA_integer_]
  overflow=F
  for (i in 1:nrow(curr_batch_pid)){
    # don't let the batch size get over max_n_per_batch
    tried = 0
    while((curr_batch_pid[i, N] + batch_sizes[[batch_iter]]) > max_n_per_batch){
      batch_iter = batch_iter + 1
      if(batch_iter == nplates){
        batch_iter = 1
        tried = tried + 1
        if(tried > nplates*2){
          overflow=T
          message(sprintf("With this randomization, '%s' samples don't fit into %s batches. Trying with %s.",b, nplates,nplates+1))
          return(list(curr_batch_pid=NULL,
                      nplates=nplates+1))
        } 
      }
    }
    curr_batch_pid[i, batch := batch_iter] # assign batch
    batch_sizes[[batch_iter]] = batch_sizes[[batch_iter]] + curr_batch_pid[i, N] # increase size
    
    # increment batch
    batch_iter = batch_iter + 1
    if(batch_iter == nplates+1){
      batch_iter = 1
    }
  }
    
  return(list(batch_assignments=curr_batch_pid,
              nplates=nplates+1))
}

for (b in unique(all_meta[,batching_group])){

  cat(sprintf("BATCHING STATS FOR '%s' SAMPLES ##############################################\n\n", b))
  
  curr_batch = unique(all_meta[batching_group == b])
  curr_batch_pid = unique(curr_batch[,.(codedsiteid, pid, randomgroupcode, sex_psca, calculatedage)])
  
  # how many samples per person?
  curr_batch_n = data.table(table(curr_batch[,pid]))
  colnames(curr_batch_n) = c('pid','N')
  
  # how many plates do we need?
  nplates = ceiling(nrow(curr_batch)/max_n_per_batch) # leave room for 2 ref stds
  # now we want to separate site and randomgroupcode across the plates. let's see if sex and age end up being random enough 

  curr_batch_pid[,pid := as.character(pid)]
  curr_batch_n[,pid := as.character(pid)]
  curr_batch_pid = merge(curr_batch_pid, curr_batch_n, by='pid')
  
  curr_batch_pid[,group := paste0(codedsiteid, randomgroupcode)]
  curr_batch_pid = curr_batch_pid[order(N, group, decreasing = T)] 
  
  batching_res = make_batches(nplates, curr_batch_pid, b)
  
  while(is.null(batching_res$batch_assignments)){
    # repeat with an additional plate 
    batching_res = make_batches(batching_res$nplates, curr_batch_pid, b)
  }
  batches = batching_res$batch_assignments
  
  cat('Sample totals:\n')
  print(batches[,list(total = sum(N)), by=batch])
  cat('\nN subj. per sex by batch:\n')
  print(table(batches[,batch], batches[,sex_psca]))
  cat('\nN subj. per site by batch:\n')
  print(table(batches[,batch], batches[,codedsiteid]))
  cat('\nN subj. per intervention by batch:\n')
  print(table(batches[,batch], batches[,randomgroupcode]))
  cat('\nN subj. per age group by batch (<40 yrs):\n')
  print(table(batches[,batch], batches[,calculatedage]<40))
  
  cat('\n\n')
  
  # write two versions to file 
  # batch characteristics 
  write.table(batches, file=sprintf("%s/precovid_%s-samples_UNBLINDED-batch-characteristics.csv", outdir, gsub(" ","-",b)), sep=',', col.names=T, row.names=F, quote=F)
  
  # current and new positions 
  curr_batch[,pid := as.character(pid)]
  all_info = merge(curr_batch, batches[,.(pid, batch)], by='pid')
  assert(nrow(all_info) == nrow(curr_batch))
  positions = all_info[,.(viallabel, barcode, sampletypecode, box, position, batch)]
  colnames(positions) = c('viallabel','barcode','sampletypecode','shipping_box','shipping_position','new_batch')
  positions[,new_batch := paste0("batch_",new_batch)]
  # order across rows 
  if(all(grepl("^[A-z]", positions[,shipping_position]))){
    positions[,shipping_row := sapply(shipping_position, function(x) unname(unlist(strsplit(x, '')))[1])] # first character
    positions[,shipping_column := sapply(shipping_position, function(x) as.numeric(paste(unname(unlist(strsplit(x, '')))[2:3],collapse='')))] # second and third characters
    positions = positions[order(shipping_box, shipping_row, shipping_column)]
    positions[,c('shipping_row','shipping_column') := NULL]
  }else if(all(grepl("^[0-9]", positions[,shipping_position]))){
    positions[,shipping_position := as.numeric(shipping_position)]
    positions = positions[order(shipping_box, shipping_position)]
  }else{
    warning("Shipping positions for '%s' samples are a combination of numbers and plate positions. How are we supposed to order these? %s",
            b,
            paste(unique(positions[,shipping_position], collapse=',')))
  }

  write.table(positions, file=sprintf("%s/precovid_%s-samples_BLINDED-batch-assignments.csv", outdir, gsub(" ","-",b)), sep=',', col.names=T, row.names=F, quote=F)
}

warnings()
