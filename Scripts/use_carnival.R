#!/usr/bin/env Rscript

library(CARNIVAL)
library(rhdf5)
library(rjson)


# Get command line input
args <- commandArgs(trailingOnly=TRUE)
input_path <- args[1]
output_path <- args[2]
solver <- args[3]
opts_path <- args[4]
dist <- FALSE
if (length(args) > 4 && as.numeric(args[5]) == 1) {
    dist <- TRUE
}

# Find appropriate executable
exec <- list(lpSolve="lp_solve", 
             cbc="cbc", 
             gurobi="gurobi_cl", 
             cplex="cplex")
solver_path <- system(paste0("which ", exec[[solver]]), intern=TRUE)

# Append CARNIVAL options
opts <- fromJSON(file=opts_path)[["CARNIVAL_OPTS"]]
opts["distributed"] <- dist
opts["solver"] <- solver
opts["solverPath"] <- solver_path
opts["workdir"] <- dirname(output_path)
opts["outputFolder"] <- dirname(output_path)

perturbations <- unlist(h5read(input_path, "inputs"))
measurements <- unlist(h5read(input_path, "meas"))
pkn <- h5read(input_path, "PKN")

# Run CARNIVAL
result <- runVanillaCarnival(perturbations = perturbations,
                             measurements = measurements,
                             priorKnowledgeNetwork = pkn,
                             weights = NULL,
                             carnivalOptions = opts)

# Save results
saveRDS(result, output_path)

