#!/usr/bin/env Rscript

repo <- "http://cran.us.r-project.org"

# Install R using: 
# ```
# conda create -n bioquant -c conda-forge jupyter jupyter_contrib_nbextensions r-base=4.0.3 python=3.8 nbconvert=5.6.1 pytz
# pip install snakemake jupytext betterbib
# ```

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repos = repo)

install.packages(c("devtools", "tidyverse", "VennDiagram", "openxlsx"), 
                 repos = repo)

# Packages often used in projects in saezlab
BiocManager::install(c("CARNIVAL", "progeny", "dorothea", "DESeq2", "pheatmap"))
BiocManager::install('OmnipathR', version = '3.12')

