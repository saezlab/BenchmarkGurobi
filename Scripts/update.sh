#!/usr/bin/env bash

export_conda() {
    ENV_NAME=${1}
    ENV_FILE_1=${2:-conda_env.yml}
    ENV_FILE_2=${3:-conda_env_simple.yml}
    conda env export -n ${ENV_NAME} -f ${ENV_FILE_1}
    conda env export -n ${ENV_NAME} -f ${ENV_FILE_2} --from-history
    if grep -q "pip:" ${ENV_FILE_1}; then 
        sed -i -e '$d' ${ENV_FILE_2} && 
            sed -n -e '/pip:/,$p' ${ENV_FILE_1} >> ${ENV_FILE_2}
    fi
}

export_renv() {
    CONDA_SOURCE=${CONDA_EXE/bin\/conda/etc\/profile.d\/conda.sh}
    ENV_NAME=${1}
    SNAPSHOT_TYPE=${2:-'all'}

    source ${CONDA_SOURCE} &&
    conda activate ${ENV_NAME} && 
    R --no-echo -e "renv::hydrate(); renv::snapshot(type=\"${SNAPSHOT_TYPE}\")"
}

