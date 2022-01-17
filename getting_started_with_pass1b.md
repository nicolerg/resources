# How to get started with PASS1B graphical clustering results  

## Get access to MoTrPAC resources

Email the MoTrPAC HelpDesk (motrpac-helpdesk@lists.stanford.edu) and ask for:  

* `gsutil` access to gs://mawg-data and gs://motrpac-data-freeze-pass
* Access to the [motrpac-mawg GitHub code repository](https://github.com/MoTrPAC/motrpac-mawg) along with your GitHub username (create a [GitHub](https://github.com/) account if you don’t have one yet)

## Access the data 

### Option 1: Recommended if you are comfortable with the command line
1. Install `gsutil` (CLI for GCP): https://cloud.google.com/storage/docs/gsutil_install  
2. Authorize your GCP credentials with `gcloud init` after the MoTrPAC HelpDesk has added you to gs://mawg-data and gs://motrpac-data-freeze-pass: https://cloud.google.com/storage/docs/gsutil_install#authenticate  
3. Clone the [motrpac-mawg GitHub repository](https://github.com/MoTrPAC/motrpac-mawg)  
    * See instructions here once you have access to the repo: https://github.com/MoTrPAC/motrpac-mawg/blob/master/docs/clone_repo.md  
    * I have also written a minimal `git` primer to help: https://github.com/MoTrPAC/motrpac-mawg/blob/master/docs/minimal_git_primer.md  
3. In R, run the following:
    ```r
    # load functions in the repository
    # 'motrpac-mawg' is the name of the folder where you cloned https://github.com/MoTrPAC/motrpac-mawg
    # you will need to adjust this path to point to ‘motrpac-mawg’ if it’s not in the current working direcctory
    source("motrpac-mawg/pass1b-06/integrative/clustering/cluster_viz_fx.R")

    # 'gsutil' is the path to your gsutil binary
    # gsutil may have been installed somewhere else on your system
    # run 'which gsutil' and copy/paste the path into this variable
    gsutil = "~/google-cloud-sdk/bin/gsutil"

    # 'outdir' is an intermediate folder where files are downloaded from GCP locally
    # before loading them into R
    outdir = "/tmp"

    # run a function in 'motrpac-mawg/pass1b-06/integrative/clustering/cluster_viz_fx.R'
    # to download and load all of the relevant data
    data = load_graph_vis_data(gsutil, outdir)
    # list all of the objects loaded
    names(data)
    ```

### Option 2: Use the GCP Console in your browser

Link to motrpac-mawg GCP Console: https://console.cloud.google.com/storage/browser/mawg-data?authuser=1

1. Once you have access to gs://mawg-data, download the following files:
    * https://storage.cloud.google.com/mawg-data/pass1b-06/merged/graphical_analysis_results_20211220.RData?authuser=1  
    * https://storage.cloud.google.com/mawg-data/pass1b-06/merged/feature_repfdr_states_20220117.tsv?authuser=1  
2. Load/read the above files into R

## Navigate the data

### For Option 1 (recommended)
* `data$sample_level_data` provides the sample-level normalized data for each sample and feature  
* `data$repfdr_feature_states` allows you to subset features by the graphical node or path they belong to  
* `data$node_sets` and `data$edge_sets` provide features in all of the edges and nodes in the repfdr graphs  
* `data$fdr_enrichment_res` provides the statistically significant pathway enrichment results  
* `data$feature_to_gene` provides the feature-to-gene map for all features (KEGG IDs are provided for metabolites instead of gene IDs)  
* Read other details [here](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/README.md) once you have access to the motrpac-mawg GitHub

### For Option 2
* `“graphical_analysis_results.RData”` loads many objects, including:  
    * `sample_level_data`: provides the sample-level normalized data for each sample and feature  
    * `edge_sets` and `node_sets` provide features in all of the edges and nodes in the repfdr graphs  
    * `fdr_enrichment_res`: provides the statistically significant pathway enrichment results  
    * Read other details [here](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/README.md) once you have access to the motrpac-mawg GitHub  
* `“feature_repfdr_states_20220117.tsv”` allows you to subset features by the graphical node or path they belong to  

## Use helpful functions to navigate the graphical clustering results  

The main benefit of Option 1 is being able to run functions that other MAWGers have written to help analysts work with the data. Many of our functions require `gsutil` access to programmatically download MoTrPAC data from GCP. Functions are loaded into R using the following commands:

```r
# load functions in the repository
# 'motrpac-mawg' is the name of the folder where you cloned https://github.com/MoTrPAC/motrpac-mawg
# you will need to adjust this path to point to ‘motrpac-mawg’ if it’s not in the current working direcctory
source("motrpac-mawg/pass1b-06/integrative/clustering/cluster_viz_fx.R")
source("motrpac-mawg/pass1b-06/integrative/clustering/graphical_analysis_functions.R")
```

Here are a few useful functions:

* [load_graph_vis_data()](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/cluster_viz_fx.R#L2265): load all graphical-clustering-related data
* [enrichment_network_vis()](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/cluster_viz_fx.R#L1870): plot an interactive network view of pathway enrichments
* [get_all_dea_results()](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/cluster_viz_fx.R#L2349): load all significant differential analysis results
* [get_tree_plot_for_tissue()](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/graphical_analysis_functions.R#L171): plot the graph for a given tissue and ome subset
* [plot_top_enrichments_for_tissue_set()](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/cluster_viz_fx.R#L833): plot the top N pathway enrichments for each tissue
* [plot_group_mean_trajectories()](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/cluster_viz_fx.R#L370): plot trajectories of sample-level data for a given set of features

See examples of how to run all of these functions in the [script used to generate the tissue-level reports](https://github.com/MoTrPAC/motrpac-mawg/blob/master/pass1b-06/integrative/clustering/graphical-res-vis-reports.Rmd).
