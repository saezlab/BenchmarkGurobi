#!/usr/bin/env Rscript

library(igraph)

# Input parameters
set.seed(snakemake@wildcards[["seed"]]) 
edge_prob = as.numeric(snakemake@wildcards[["prob"]])
num_nodes = as.numeric(snakemake@wildcards[["nodes"]])
num_inputs = as.numeric(snakemake@wildcards[["inputs"]])
num_measurments = as.numeric(snakemake@wildcards[["meas"]])

# We create appropriate labels
labels_inputs = paste0("I", 1:num_inputs)
labels_meas = paste0("M", 1:num_measurments)
lebels_rest = paste0("N", 1:(num_nodes - num_inputs - num_measurments))
labels = c(labels_inputs, labels_meas, lebels_rest)

# We create the network using igraph library
g <- igraph::erdos.renyi.game(num_nodes, edge_prob, "gnp", directed = TRUE)
while (igraph::count_components(g) > 1) {
    g <- igraph::erdos.renyi.game(num_nodes, edge_prob, "gnp", directed = TRUE)
}
g <- igraph::set.vertex.attribute(g, "name", value=labels)
saveRDS(g, snakemake@output[[2]])

# We convert the graph to a dataframe
df <- igraph::as_data_frame(g, what="edges")
colnames(df) <- c("Source", "Target")
df["Effect"] = rep(1, nrow(df))
df <- df[, c(1, 3, 2)]

# We create input and measurments dataframes
inputs <- data.frame(t(rep(1, num_inputs)))
colnames(inputs) <- labels_inputs
meas <- data.frame(t(rep(1, num_measurments)))
colnames(meas) <- labels_meas

carnival_input <- list(inputObj = inputs, measObj = meas, netObj = df)
saveRDS(carnival_input, snakemake@output[[1]])

