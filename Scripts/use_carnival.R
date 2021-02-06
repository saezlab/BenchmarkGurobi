
library(CARNIVAL)


input_data <- readRDS(snakemake@input[[1]])

res = runCARNIVAL(solverPath = snakemake@config[[snakemake@wildcards[["solver"]]]], 
                  inputObj = input_data$inputObj, 
                  measObj = input_data$measObj, 
                  netObj = input_data$netObj)

saveRDS(res, snakemake@output[[1]])
