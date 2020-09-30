#!/bin/bash

echo "**** run_test.sh starting"
echo "**** mpi: $mpi"
echo "**** python: $($PYTHON --version)"
echo "**** SKIP_TESTS_MPI: $SKIP_TESTS_MPI"
echo "**** SKIP_TESTS_NOMPI: $SKIP_TESTS_NOMPI"


if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
    if [[ "$SKIP_TESTS_MPI" = "yes" ]]; then
        echo "Skipping tests for MPI build, as directed."
        exit 0
    fi
    for t in python/tests/*.py; do
        if [ "$(basename $t)" != "material_dispersion.py" -a "$(basename $t)" != "mpb.py" ]; then
            echo "Running $(basename $t)"
            OPENBLAS_NUM_THREADS=1 ${PREFIX}/bin/mpiexec -n 2 $PYTHON $t
        fi
    done
else
    if [[ "$SKIP_TESTS_NOMPI" = "yes" ]]; then
        echo "Skipping tests for NOMPI build, as directed."
        exit 0
    fi
    # Mac builds are over the 50 minute time limit on Travis. Skip the serial
    # tests until we find a way to speed things up
    if [[ $(uname) == Linux ]]; then
        for t in $(find python/tests -name "*.py" | sed /mpb/d); do
            echo "Running $(basename $t)"
            OPENBLAS_NUM_THREADS=1 $PYTHON $t
        done
    else
        echo "Skipping NOMPI tests on OSX."
    fi
fi
