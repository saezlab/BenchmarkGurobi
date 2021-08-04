
SHELL:=/bin/bash

ENV_NAME := bq

CONDA_SOURCE := $(patsubst %bin/conda,%etc/profile.d/conda.sh,${CONDA_EXE})

all: conda_env.yml conda_env_simple.yml renv.lock

conda_env.yml:
	conda env export -n ${ENV_NAME} -f $@

conda_env_simple.yml: conda_env.yml
	conda env export -n ${ENV_NAME} -f $@ --from-history
	if grep -q 'pip:' $^ ; then sed -i -e '$$d' $@ && sed -n -e '/pip:/,$$p' $^ >> $@; fi

.Rprofile:
	R -e "library(renv); renv::init()"

renv.lock:
	source ${CONDA_SOURCE} && conda activate ${ENV_NAME} && R -e "library(renv); renv::hydrate(); renv::snapshot()"

.git/hooks/pre-commit:
	ln -s ../../.pre-commit $@

DATE = $(shell date +"%Y_%m_%d_%H_%M")
new_archive:
	mkdir -p Archive && tar -zcvf Archive/output_${DATE}.tar.gz Output/

clean: 
	rm -rf README.md main.py.md Images/

clean_test:
	rm -rf Output/*/E10_N8_I3_M2_S1_P2_2/

wipe: clean
	rm -rf Output/ Logs/

