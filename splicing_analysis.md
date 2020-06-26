## Resources: 
- [Introduction to RNA-seq](https://www.youtube.com/watch?v=tlf6wYJrwKY&list=PLblh5JKOoLUJo2Q6xK4tZElbIvAACEykp)
- ["The Expanding Landscape of Alternative Splicing Variation in Human Populations"](https://www-cell-com.stanford.idm.oclc.org/ajhg/pdf/S0002-9297(17)30454-8.pdf) splicing review
- [Leafcutter vignette](http://davidaknowles.github.io/leafcutter/)
- [Alignment and quantification tutorial](https://github.com/smontgomlab/bios201/tree/master/Workshop2)
- [STAR manual](https://physiology.med.cornell.edu/faculty/skrabanek/lab/angsd/lecture_notes/STARmanual.pdf) (see section 8)

## Workflow 
1. Requantify BAMs?
2. Process BAMs for `leafcutter`
3. Run `leafcutter`

## Run `leafcutter` on SCG
```{bash}
module load legacy
module load leafcutter #0.2.7 (newest version as of 6/15/20 is 0.2.9)  
```
## Previous STAR outputs  
STAR index:  
```{bash}
##Assuming genome.fa and genome.gtf is in the current folder
threads=$1
STAR --runThreadN $threads\
     --runMode genomeGenerate\
     --genomeDir star_index\
     --genomeFastaFiles genome.fa\
     --sjdbGTFfile genome.gtf\
     --sjdbOverhang 100\
     --outFileNamePrefix star_index/ 
```
Ouptuts available: `/oak/stanford/groups/smontgom/nicolerg/MOTRPAC/RNA/REFERENCES/rn6_ensembl_r95/star_index`  

First pass alignment:  
```{bash}
# SID is the viallabel (file name prefix)
# code used to do first pass alignment:
STAR  --genomeDir $gdir/star_index\
      --sjdbOverhang  100\
      --readFilesIn "$@"\
      --outFileNamePrefix star_align/${SID}/\
      --readFilesCommand zcat \
      --outSAMattributes NH HI AS NM MD nM\
      --runThreadN $threads\
      --outSAMtype BAM SortedByCoordinate\
      --outFilterType BySJout\
      --quantMode TranscriptomeSAM\
      --outTmpDir $tmpdir/tmp
```
Inputs: pairs of trimmed FASTQ files  
Outputs:   
- ${viallabel}.SJ.out.tab files (splice junctions)  
- BAM file from first pass alignment (you won't need this)  

## Second pass alignment to generate leafCutter input 
This is your starting point. Refer to Section 8 of the STAR manual, linked above, and refer to the "multi-sample 2nd pass mapping" section. A combination of the commands shown here and the commands used in the leafCutter vignette are what you will need to use to map the FASTQs a second time with correct parameters.  
