
all: conda_env.yml r_packages.csv

conda_env.yml:
	conda env export -n bioquant --file conda_env.yml

r_packages.csv:
	R --slave -e "write.csv(installed.packages(), 'r_packages.csv')"

clean:
	rm -f conda_env.yml r_packages.csv
