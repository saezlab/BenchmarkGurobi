
import json
from itertools import product
from os import path, makedirs
import socket


if "uni-heidelberg" in socket.gethostname():
    shell.prefix("module load numlib/gurobi math/lpsolve;")

if not path.isdir("Logs"): makedirs("Logs")
if not path.isdir("Images"): makedirs("Images")

configfile: "config.json"

rule all:
    input:
        "main.py.md"
    output:
        "README.md"
    shell:
        "cp {input} {output}"

rule igraph_input:
    output:
        "Output/{network}/E{e}_N{n}_I{i}_M{m}_S{seed}/carnival_input.h5",
        "Output/{network}/E{e}_N{n}_I{i}_M{m}_S{seed}/carnival_input.dot"
    params:
        network = "{e} {n} {i} {m} {network}"
    shell:
        "Scripts/gen_igraph_input.R {params.network} {output[0]} {wildcards.seed}"

rule install_carnival:
    output:
        "Logs/carnival.log"
    params:
        install=(f"\"{config['INSTALL']['URL']}\", "
                 f"ref=\"{config['INSTALL']['ref']}\", "
                 f"force={config['INSTALL']['force']}, "
                 f"dependencies={config['INSTALL']['dependencies']}")
    shell:
        "R --slave -e 'devtools::install_github({params.install})' 2>&1 | "
        "tee {output}"

def get_time(wildcards):
    num_edges = int(wildcards.dataset.split("/")[1].split("_")[0].strip("E"))
    return int(30 + num_edges/250)

rule use_carnival:
    input:
        "Output/{dataset}/carnival_input.h5",
        "Logs/carnival.log"
    output:
        "Output/{dataset}/{solver}_N{nodes}/result.Rds"
    params:
        distributed = lambda wildcards : int(int(wildcards.nodes) > 1)
    resources:
        time_min = lambda wildcards, attempt : attempt * get_time(wildcards),
        nodes = lambda wildcards : wildcards.nodes,
        partition = lambda wildcards : 
            "multi" if int(wildcards.nodes) > 1 else "single",
        extra = lambda wildcards : 
            "--constraint=gurobi" if int(wildcards.nodes) > 1 else ""
    benchmark:
        "Output/{dataset}/{solver}_N{nodes}/benchmark.tsv"
    log:
        "Output/{dataset}/{solver}_N{nodes}/log.txt"
    shell:
        "Rscript Scripts/use_carnival.R {input[0]} {output[0]} "
        "{wildcards.solver} config.json {params.distributed} 2>&1 | tee {log}"

rule test:
    input:
        expand("Output/{network}/E10_N8_I3_M2_S1/{solver}_N1/result.Rds", 
                solver=["lpSolve", "cbc", "cplex", "gurobi"], 
                network=["Powerlaw", "Erdos"])

rule erdos_benchmarks:
    input:
        [f"Output/Erdos/E{3*n}_N{n}_I10_M10_S1/{s}_N1/result.Rds" for n, s 
                in product(range(50, 2000, 50), ["cbc", "cplex", "gurobi"])]

rule powerlaw_benchmarks:
    input:
        [f"Output/Powerlaw/E{4*n}_N{n}_I10_M10_S1/{s}_N1/result.Rds" for n, s 
                in product(range(50, 1000, 50), ["cbc", "cplex", "gurobi"])]

rule distributed_benchmarks:
    input:
        [f"Output/Erdos/E3000_N1000_I10_M10_S1/gurobi_N{n}/result.Rds" for n 
                in range(1, 10)] 

rule export_notebook:
    input:
        "main.py.ipynb",
        expand("Images/example_{solver}.svg", solver=("cplex", "gurobi"))
    output:
        "main.py.{fmt}"
    params:
        fmt = lambda wildcards : "markdown" if wildcards.fmt == "md" else wildcards.fmt,
        images = "--NbConvertApp.output_files_dir Images"
    shell:
        "sed -i \"s/matplotlib notebook/matplotlib inline/\" {input[0]} && "
        "jupyter-nbconvert --to {params.fmt} {params.images} --execute {input[0]}"

rule use_dot:
    input:
        "Output/{filepath}.dot"
    output:
        "Output/{filepath}.svg"
    shell:
        "dot {input} -T svg > {output}"

rule rulegraph:
    output:
        "Images/rulegraph.svg"
    shell:
        "snakemake --rulegraph all | dot -Tsvg > {output}"

rule save_env:
    output:
        "conda_env.yml"
    shell:
        "conda env export -n bioquant_devel --file {output}"
    
