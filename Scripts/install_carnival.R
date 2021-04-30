#!/usr/bin/env Rscript

# This script is needed as conda cannot install an R package from github

library(devtools)

args <- commandArgs(trailingOnly=TRUE)
output_file <- args[1]

url <- "git@github.com:BartoszBartmanski/CARNIVAL.git"
branch <- "gurobi"

devtools::install_github(url, ref=branch, dependencies = FALSE)

write(" ", file=output_file)
