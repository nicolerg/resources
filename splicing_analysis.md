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
