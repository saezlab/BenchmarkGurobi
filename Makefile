
all: conda_env.yml

install_carnival_devel:
	R --slave -e "devtools::install_github('https://github.com/saezlab/CARNIVAL.git', dependencies = FALSE)"

install_carnival_gurobi:
	R --slave -e "devtools::install_github('git@github.com:BartoszBartmanski/CARNIVAL.git', ref='gurobi', dependencies = FALSE)"

conda_env.yml:
	conda env export -n bioquant_devel --file $@

clean: 
	rm -rf README.md main.py.md main.py_files/

clean_test:
	rm -rf Output/*/E10_N8_I3_M2_S1_P2_2/

wipe: clean_test clean

