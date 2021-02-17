#!/usr/bin/env Rscript

repo <- "http://cran.us.r-project.org"

# Install R using: 
# ```
# conda create -n bioquant -c conda-forge jupyter jupyter_contrib_nbextensions r-base=4.0.3 python=3.8 nbconvert=5.6.1 pytz
# pip install snakemake jupytext betterbib
# ```

install.packages(c("devtools", "tidyverse", "VennDiagram", 
                   "openxlsx", "BiocManager", "reshape2"), 
                 repos = repo)
BiocManager::install('OmnipathR', version = '3.12')
devtools::install_github('saezlab/CARNIVAL')

