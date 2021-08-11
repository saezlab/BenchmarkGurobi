
SHELL:=/bin/bash

ENV_NAME := bq

all: conda_env.yml conda_env_simple.yml renv.lock

conda_env.yml:
	conda env export -n ${ENV_NAME} -f $@

conda_env_simple.yml: conda_env.yml
	source Scripts/update.sh && export_conda ${ENV_NAME} $^ $@

.Rprofile:
	R -e "library(renv); renv::init()"

renv.lock:
	source Scripts/update.sh && export_renv ${ENV_NAME}

.git/hooks/pre-commit:
	ln -s ../../.pre-commit $@

DATE = $(shell date +"%Y_%m_%d_%H_%M")
.PHONY: new_archive
new_archive:
	mkdir -p Archive && tar -zcvf Archive/output_${DATE}.tar.gz Output/

clean: 
	rm -rf README.md main.py.md Images/

clean_test:
	rm -rf Output/*/E10_N8_I3_M2_S1_P2_2/

wipe: clean
	rm -rf Output/ Logs/

