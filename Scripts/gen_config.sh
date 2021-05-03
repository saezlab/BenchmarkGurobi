#!/usr/bin/env bash

output_file=${1:-config.json}

printf "{\n" > ${output_file}
printf "\t\"lpSolve\": \"$(which lp_solve)\",\n" >> ${output_file}
printf "\t\"cbc\": \"$(which cbc)\",\n" >> ${output_file}
printf "\t\"cplex\": \"$(which cplex)\",\n" >> ${output_file}
printf "\t\"gurobi\": \"$(which gurobi_cl)\"\n" >> ${output_file}
printf "}\n" >> ${output_file}
