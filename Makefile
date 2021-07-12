
conda_env.yml:
	conda env export -n bioquant_devel --file $@

clean: 
	rm -rf README.md main.py.md main.py_files/ conda_env.yml

clean_test:
	rm -rf Output/*/E10_N8_I3_M2_S1_P2_2/

wipe: clean
	rm -rf Output/ Logs/

