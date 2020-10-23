# Phenotype associations with molecular measurements 

## Likelihood ratio tests to test for the significance of the interaction between sex and training  
- Full model: `vo2 ~ sex + time + sex:time`
- Reduced model: `vo2 ~ sex + time` 

## Likelihood ratio tests to test for the significance of analyte as a predictor 
- Full model: `vo2 ~ sex + time + sex:analyte + analyte`
- Reduced model: `vo2 ~ sex + time`

## Assessing likelihood ratio tests  
Save two values from each test:  
- p-value (does the full model explain significantly more variance relative to the reduced model?) 
- likelihood ratio (roughly interpreted as how much additional variance is explained by the full model relative to the reduced model)  
