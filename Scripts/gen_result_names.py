#!/usr/bin/env python

import argparse
from itertools import product
import numpy as np


class SplitArgs(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, values.split(','))

class SplitArgsInt(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, [int(x) for x in values.split(',')])

def main(num_nodes, types, solvers, num_in=10, num_meas=10, ratio=3):

    prefix = "Output"
    suffix1 = f"_I{num_in}_M{num_meas}_S1_P2_2"
    suffix2 = "result.Rds"
    num_edges = ratio * np.array(num_nodes)
    sizes = [f"E{e}_N{n}{suffix1}" for e, n in zip(num_edges, num_nodes)]
    it = product(types, sizes, solvers)

    return [f"{prefix}/{x}/{y}/{z}/{suffix2}" for x, y, z in it]


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("num_nodes", action=SplitArgsInt, help="List of number of nodes")
    parser.add_argument("-t", "--types", action=SplitArgs, default=["Erdos"],
                        help="List of types of networks")
    parser.add_argument("-s", "--solvers", action=SplitArgs, default=["gurobi"],
                        help="List of solvers")
    parser.add_argument("--ratio", default=3, type=int, 
                        help="Ratio between number of edges and number of nodes")
    parser.add_argument("-i", "--num_in", default=10, type=int,
                        help="Number of input nodes")
    parser.add_argument("-m", "--num_meas", default=10, type=int, 
                        help="Number of measurment nodes")
    args = parser.parse_args()

    print(*main(**vars(args)))

