# Phenotype associations with molecular measurements 

## How to code VO2max
- Percent change in VO2max: `(second test - first test)/(first test)*100`
- VO2max normalized to lean mass
- VO2max normalized to total mass 

## Likelihood ratio tests to test for the significance of the interaction between sex and training  
- Full model: `vo2 ~ sex + time + sex:time`
- Reduced model: `vo2 ~ sex + time`  
Time should be coded as a number: 0, 1, 2, 4, or 8. 

## Likelihood ratio tests to test for the significance of analyte as a predictor 
- Full model: `vo2 ~ sex + time + sex:analyte + analyte`
- Reduced model: `vo2 ~ sex + time`  
Time should be coded as a number: 0, 1, 2, 4, or 8. 

## Assessing likelihood ratio tests  
Save two values from each test:  
- p-value (does the full model explain significantly more variance relative to the reduced model?) 
- likelihood ratio (roughly interpreted as how much additional variance is explained by the full model relative to the reduced model)  

Look at distributions of each of these values.  
Plot individual analytes with the highest likelihood ratios (or smallest p-values). 
