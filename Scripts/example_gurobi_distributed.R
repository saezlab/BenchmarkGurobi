#!/usr/bin/env Rscript
#SBATCH --job-name="gurobi_test"        # Define job name
#SBATCH --time=00:05:00                 # wall−clock time (min:sec)
#SBATCH -p multi                        # Submit to multi partition
#SBATCH -n 3                            # number of tasks in job
#SBATCH --nodes=3                       # reserve several nodes
#SBATCH --output=gurobi_output_%j.log   # output filename
#SBATCH --mem=1gb                       # Amount of mem per job
#SBATCH --constraint=gurobi             # Constraint necessary for running gurobi_rs jobs.


##### Download ##### 
# https://gist.github.com/BartoszBartmanski/8fab8256f55516a6ba021006b26d2618

##### To run this script #####
# 1. Activate conda environment with R and CARNIVAL installed
# 2. Load gurobi using `module load numlib/gurobi`
# 3. Submit the script as a new job to slurm with `sbatch example_gurobi_distributed.R`


library(CARNIVAL)


correct_input <- function(data_frame) {
    if (is.data.frame(data_frame)) {
        perturbationNames <- colnames(data_frame)
        inputObj <- as.vector(t(data_frame))
        names(inputObj) <- perturbationNames
    } else {
        inputObj <- data_frame
    }

    return(inputObj)
}

load(file = system.file("toy_inputs_ex1.RData", package="CARNIVAL"))
load(file = system.file("toy_measurements_ex1.RData", package="CARNIVAL"))
load(file = system.file("toy_network_ex1.RData", package="CARNIVAL"))

# Get the path for gurobi
path_to_gurobi <- system("which gurobi_cl", intern=TRUE)
if (length(path_to_gurobi) == 0) {
    stop("gurobi could not be found!")
}

# Define carnival parameters
opts <- list(solverPath = path_to_gurobi, 
             solver = "gurobi", 
             distributed=TRUE,
             WorkerPassword="sXa78c2vYVK0ft4zYyqb",
             timelimit = 3600, 
             mipGap = 0.05, 
             poolrelGap = 0.0001, 
             limitPop = 500,
             poolCap = 100,
             poolIntensity = 4,
             poolReplace = 2,
             alphaWeight = 1,
             betaWeight = 0.2,
             threads = 0,
             cleanTmpFiles = TRUE,
             keepLPFiles = TRUE,
             clonelog = -1,
             workdir = "./",
             outputFolder = "./")

# Run carnival
result <- runVanillaCarnival(perturbations = correct_input(toy_inputs_ex1),
                             measurements = correct_input(toy_measurements_ex1),
                             priorKnowledgeNetwork = toy_network_ex1,
                             weights = NULL,
                             carnivalOptions = opts)

print(result)

# Save results
saveRDS(result, "result.Rds")

