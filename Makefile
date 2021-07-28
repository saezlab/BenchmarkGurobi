
ENV_NAME=bq_dev

conda_env.yml:
	conda env export -n ${ENV_NAME} --file $@

.git/hooks/pre-commit:
	ln -s ../../.pre-commit $@

DATE = $(shell date +"%Y_%m_%d_%H_%M")
new_archive:
	mkdir -p Archive && tar -zcvf Archive/output_${DATE}.tar.gz Output/

clean: 
	rm -rf README.md main.py.md conda_env.yml Images/

clean_test:
	rm -rf Output/*/E10_N8_I3_M2_S1_P2_2/

wipe: clean
	rm -rf Output/ Logs/

