
configfile: "solvers.json"

rule all:
    input:
        "conda_env.yml", 
        "r_packages.csv"

rule save_env:
    output:
        "conda_env.yml"
    shell:
        "conda env export -n bioquant --file {output}"

rule save_packages:
    output:
        "r_packages.csv"
    shell:
        "R --slave -e \"write.csv(installed.packages(), 'r_packages.csv')\""

rule use_dot:
    input:
        "{dataset}/network_solution.dot"
    output:
        "{dataset}/network_solution.{filetype}"
    shell:
        "dot {input} -T {wildcards.filetype} > {output}"

rule generate_input:
    output:
        "Output/N{nodes}_I{inputs}_M{meas}_S{seed}_P{prob}/carnival_input.Rds",
        "Output/N{nodes}_I{inputs}_M{meas}_S{seed}_P{prob}/graph.Rds",
    script:
        "Scripts/generate_input.R"

rule use_carnival:
    input:
        "Output/N{nodes}_I{inputs}_M{meas}_S{seed}_P{prob}/carnival_input.Rds"
    output:
        "Output/N{nodes}_I{inputs}_M{meas}_S{seed}_P{prob}/{solver}/result.Rds"
    benchmark:
        repeat("Output/N{nodes}_I{inputs}_M{meas}_S{seed}_P{prob}/{solver}/benchmark.tsv", 5)
    script:
        "Scripts/use_carnival.R"

rule test:
    input:
        expand("Output/N8_I3_M2_S1_P0.2/{solver}/result.Rds", 
                solver=["lpsolve", "cbc", "cplex"])

