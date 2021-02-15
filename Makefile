
all: conda_env.yml r_packages.csv

conda_env.yml:
	conda env export -n bioquant_devel --file $@

r_packages.csv:
	R --slave -e "write.csv(installed.packages()[, c('Package', 'Version')], 'r_packages.csv')"

clean:
	rm -f conda_env.yml r_packages.csv
