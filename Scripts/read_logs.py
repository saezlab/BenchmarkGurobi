#!/usr/bin/env python


class SolverLogs(object):
    def __init__(self, filenames):
        self.__data__ = {x: getattr(self, f"__get_{x}__")(y) for x, y in filenames.items()}

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

