#!/usr/bin/env Rscript

library(igraph)
library(rhdf5)


args = commandArgs(trailingOnly=TRUE)

# Input parameters
num_edges = as.numeric(args[1])
num_nodes = as.numeric(args[2])
num_inputs = as.numeric(args[3])
num_measurments = as.numeric(args[4])
network = args[5]
outputfile = args[6]
exp_out = 2
exp_in = 2
seed = 0
if (length(args) > 6) {
    seed = as.numeric(args[7])
}
set.seed(seed)

# We create appropriate labels
labels_inputs = paste0("I", 1:num_inputs)
labels_meas = paste0("M", 1:num_measurments)
lebels_rest = paste0("N", 1:(num_nodes - num_inputs - num_measurments))
labels = c(labels_inputs, labels_meas, lebels_rest)

# We create the network using igraph library
if (network == "Erdos") {
    g <- igraph::erdos.renyi.game(num_nodes, num_edges, "gnm", directed = TRUE)
    while (igraph::count_components(g) > 1) {
        g <- igraph::erdos.renyi.game(num_nodes, num_edges, "gnm", directed = TRUE)
    }
} else if (network == "Powerlaw") {
    g <- igraph::static.power.law.game(num_nodes, num_edges, exp_out, exp_in)
    while (igraph::count_components(g) > 1) {
        g <- igraph::static.power.law.game(num_nodes, num_edges, exp_out, exp_in)
    }
}
g <- igraph::set.vertex.attribute(g, "name", value=labels)
g <- igraph::set.vertex.attribute(g, "label", value=labels)
write_graph(g, sub(".h5", ".dot", outputfile), "dot")

# We convert the graph to a dataframe
df <- igraph::as_data_frame(g, what="edges")
colnames(df) <- c("source", "target")
df["interaction"] = rep(1, nrow(df))
df <- df[, c(1, 3, 2)]

# We create input and measurments dataframes
inputs <- as.list(rep(1, num_inputs))
names(inputs) <- labels_inputs
meas <- as.list(rep(1, num_measurments))
names(meas) <- labels_meas

h5createFile(outputfile)
h5write(df, outputfile, "PKN")
h5write(meas, outputfile, "meas")
h5write(inputs, outputfile, "inputs")
h5closeAll()

