
import json
from os import path, makedirs
import socket

if "bioquant" in socket.gethostname():
    shell.prefix("module load numlib/gurobi math/lpsolve;")

if not path.isdir("Logs"): makedirs("Logs")
if not path.isdir("Images"): makedirs("Images")

rule all:
    input:
        "main.py.md"
    output:
        "README.md"
    shell:
        "cp {input} {output}"

rule test:
    input:
        expand("Output/{network}/E10_N8_I3_M2_S1_P2_2/{solver}/result.Rds", 
                solver=["lpSolve", "cbc", "cplex", "gurobi"], 
                network=["Powerlaw", "Erdos"])

rule igraph_input:
    output:
        "Output/{network}/E{edges}_N{nodes}_I{inputs}_M{meas}_S{seed}_P{exp_in}_{exp_out}/carnival_input.Rds",
        "Output/{network}/E{edges}_N{nodes}_I{inputs}_M{meas}_S{seed}_P{exp_in}_{exp_out}/interactions.csv",
        "Output/{network}/E{edges}_N{nodes}_I{inputs}_M{meas}_S{seed}_P{exp_in}_{exp_out}/graph.Rds",
        "Output/{network}/E{edges}_N{nodes}_I{inputs}_M{meas}_S{seed}_P{exp_in}_{exp_out}/graph.dot"
    script:
        "Scripts/generate_igraph_input.R"

rule omnipath_input:
    input:
        "Input/measurments.csv"
    output:
        "Output/Omnipath/measurments.csv",
        "Output/Omnipath/pkn.csv",
        "Output/Omnipath/input.csv",
        "Output/Omnipath/carnival_input.Rds"
    script:
        "Scripts/generate_omnipath_input.R"

rule install_carnival:
    output:
        ".carnival"
    params:
        url = "git@github.com:BartoszBartmanski/CARNIVAL.git",
        branch = "gurobi"
    shell:
        "R --slave -e 'devtools::install_github(\"{params.url}\", "
        "ref=\"{params.branch}\", dependencies=FALSE)' && touch {output}"

rule gen_config:
    output:
        "config.json"
    shell:
        "Scripts/gen_config.sh {output}"

def get_solver(wildcards, input):
    if path.isfile(input[1]):
        with open(input[1]) as fh:
            return json.load(fh)[wildcards.solver]
    else:
        return ""

rule use_carnival:
    input:
        "Output/{dataset}/carnival_input.Rds",
        "config.json",
        ".carnival"
    output:
        "Output/{dataset}/{solver}/result.Rds",
        "Output/{dataset}/{solver}/network_solution.dot"
    params:
        solver_path = get_solver
    shadow: 
        "shallow"
    benchmark:
        repeat("Output/{dataset}/{solver}/benchmark.tsv", 5)
    log:
        "Output/{dataset}/{solver}/log.txt"
    shell:
        "Rscript Scripts/use_carnival.R {input[0]} {output[0]} "
        "{wildcards.solver} {params.solver_path} 2>&1 | tee {log}"

rule use_dot:
    input:
        "Output/{filepath}.dot"
    output:
        "Output/{filepath}.{filetype}"
    shell:
        "dot {input} -T {wildcards.filetype} > {output}"

rule example_cplex:
    input:
        "Output/Erdos/E300_N100_I10_M10_S1_P2_2/cplex/network_solution.svg"
    output:
        "Images/example_cplex.svg"
    shell:
        "cp {input} {output}"

rule example_gurobi:
    input:
        "Output/Erdos/E300_N100_I10_M10_S1_P2_2/gurobi/network_solution.svg"
    output:
        "Images/example_gurobi.svg"
    shell:
        "cp {input} {output}"

rule export_notebook:
    input:
        "main.py.ipynb",
        expand("Images/example_{solver}.svg", solver=("cplex", "gurobi"))
    output:
        "main.py.{fmt}"
    params:
        fmt = lambda wildcards : "markdown" if wildcards.fmt == "md" else wildcards.fmt
    shell:
        "jupyter-nbconvert --to {params.fmt} --execute {input[0]}"

rule save_env:
    output:
        "conda_env.yml"
    shell:
        "conda env export -n bioquant_devel --file {output}"
    
