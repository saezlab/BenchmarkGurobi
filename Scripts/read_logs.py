#!/usr/bin/env python

import pandas as pd


class SolverLogs(object):
    def __init__(self, solver, filename):
        self.__data__ = getattr(self, f"__get_{solver}__")(filename)

    def __getitem__(self, key):
        return self.__data__[key]
    
    def get_data(self):
        return self.__data__
        
    def __get_cbc__(self, path_to_log):
        obj_val = 0
        with open(path_to_log) as fh:
            for line in fh:
                if "Objective value:" in line:
                    obj_val = float(line.split("Objective value:")[-1].strip("\n "))
        return {"objective_value": obj_val, "solution_count": 1}
    
    def __get_cplex__(self, path_to_log):
        obj_val = 0
        sol_count = 0
        with open(path_to_log) as fh:
            for line in fh:
                if "Objective = " in line:
                    obj_val = float(line.split("Objective = ")[-1].strip("\n "))
                if "Solution pool:" in line:
                    sol_count = int(line.split(" ")[2])
        return {"objective_value": obj_val, "solution_count": sol_count}

    def __get_gurobi__(self, path_to_log):
        obj_val = 0
        sol_count = 0
        with open(path_to_log) as fh:
            for line in fh:
                if "Best objective" in line:
                    obj_val = float(line.split(",")[0].split("Best objective")[-1].strip("\n "))
                if "Solution count" in line:
                    sol_count = int(line.split(":")[0].split(" ")[-1])
        return {"objective_value": obj_val, "solution_count": sol_count}

def get_results(edges, 
                nodes, 
                solver="gurobi", 
                network_type="Erdos", 
                num_in=10, 
                num_meas=10, 
                seed=0, 
                parallel=1, 
                path_prefix="Output"):

    dirname = f"{path_prefix}/{network_type}/E{edges}_N{nodes}_I{num_in}_M{num_meas}_S{seed}/"

    logs = SolverLogs(solver, f"{dirname}{solver}_N{parallel}/log.txt")
    benchmarks = pd.read_csv(f"{dirname}{solver}_N{parallel}/benchmark.tsv", "\t")

    res = {"Execution time [min]": benchmarks["s"].mean()/60, 
           "Memory [MB]": benchmarks["max_rss"].mean(),
           "Obj. value": logs["objective_value"], 
           "Number of solutions": logs["solution_count"]}
    return res
