
all: conda_env.yml r_packages.csv

conda_env.yml:
	conda env export -n bioquant_devel --file $@

r_packages.csv:
	R --slave -e "write.csv(installed.packages()[, c('Package', 'Version')], 'r_packages.csv')"

clean_test:
	rm -rf Output/*/E10_N8_I3_M2_S1_P2_2/

clean:
	rm -f conda_env.yml r_packages.csv
