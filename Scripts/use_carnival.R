
library(CARNIVAL)

args <- commandArgs(trailingOnly=TRUE)
input_path <- args[1]
output_path <- args[2]
solver <- args[3]
solver_path <- args[4]


input_data <- readRDS(input_path)

res <- runCARNIVAL(solver = solver, 
                   solverPath = solver_path, 
                   inputObj = input_data$inputObj, 
                   measObj = input_data$measObj, 
                   netObj = input_data$netObj, 
                   dir_name=dirname(output_path))

saveRDS(res, output_path)
