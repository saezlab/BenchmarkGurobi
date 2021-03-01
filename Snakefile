
configfile: "solvers.json"

rule all:
    input:
        "conda_env.yml", 
        "r_packages.csv"

rule test:
    input:
        expand("Output/Erdos/E10_N8_I3_M2_S1_P2_2/{solver}/result.Rds", 
                solver=["lpSolve", "cbc", "cplex"])

rule save_env:
    output:
        "conda_env.yml"
    shell:
        "conda env export -n bioquant_devel --file {output}"

rule save_packages:
    output:
        "r_packages.csv"
    shell:
        "R --slave -e \"write.csv(installed.packages()[, c('Package', 'Version')], 'r_packages.csv')\""

rule use_dot:
    input:
        "{dataset}/network_solution.dot"
    output:
        "{dataset}/network_solution.{filetype}"
    shell:
        "dot {input} -T {wildcards.filetype} > {output}"

rule generate_input:
    output:
        "Output/{network}/E{edges}_N{nodes}_I{inputs}_M{meas}_S{seed}_P{exp_in}_{exp_out}/carnival_input.Rds",
        "Output/{network}/E{edges}_N{nodes}_I{inputs}_M{meas}_S{seed}_P{exp_in}_{exp_out}/interactions.csv",
        "Output/{network}/E{edges}_N{nodes}_I{inputs}_M{meas}_S{seed}_P{exp_in}_{exp_out}/graph.Rds",
    script:
        "Scripts/generate_input.R"

rule use_carnival:
    input:
        "Output/{dataset}/carnival_input.Rds"
    output:
        "Output/{dataset}/{solver}/result.Rds"
    shadow: 
        "shallow"
    benchmark:
        repeat("Output/{dataset}/{solver}/benchmark.tsv", 5)
    script:
        "Scripts/use_carnival.R"

