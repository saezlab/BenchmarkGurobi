
configfile: "solvers.json"

rule test:
    input:
        expand("Output/{network}/E10_N8_I3_M2_S1_P2_2/{solver}/result.Rds", 
                solver=["lpSolve", "cbc", "cplex", "gurobi"], 
                network=["Powerlaw", "Erdos"])

rule save_env:
    output:
        "conda_env.yml"
    shell:
        "conda env export -n bioquant_devel --file {output}"

rule use_dot:
    input:
        "{filepath}.dot"
    output:
        "{filepath}.{filetype}"
    shell:
        "dot {input} -T {wildcards.filetype} > {output}"

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

rule use_carnival:
    input:
        "Output/{dataset}/carnival_input.Rds"
    output:
        "Output/{dataset}/{solver}/result.Rds",
        "Output/{dataset}/{solver}/network_solution.dot"
    params:
        solver_path = lambda wildcards : config[wildcards.solver]
    shadow: 
        "shallow"
    benchmark:
        repeat("Output/{dataset}/{solver}/benchmark.tsv", 5)
    log:
        "Output/{dataset}/{solver}/log.txt"
    shell:
        "Rscript Scripts/use_carnival.R {input} {output[0]} {wildcards.solver} {params.solver_path} > {log} 2>&1"

