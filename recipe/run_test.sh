#!/bin/bash

echo "**** run_test.sh starting"
echo "**** mpi: $mpi"
echo "**** python: $($PYTHON --version)"

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
    for t in python/tests/*.py; do
        if [ "$(basename $t)" != "material_dispersion.py" -a "$(basename $t)" != "mpb.py" ]; then
            echo "Running $(basename $t)"
            OPENBLAS_NUM_THREADS=1 ${PREFIX}/bin/mpiexec -n 2 $PYTHON $t
        fi
    done
else
    # Mac builds are over the 50 minute time limit on Travis. Skip the serial
    # tests until we find a way to speed things up
    if [[ $(uname) == Linux ]]; then
        export OPENBLAS_NUM_THREADS=1
        export OMP_NUM_THREADS=1
        #find python/tests -name "*.py" | sed /mpb/d | parallel -v "$PYTHON {}"

        for t in $(find python/tests -name "*.py" | sed /mpb/d); do
            echo "Running $(basename $t)"
            $PYTHON $t
        done
    fi
fi
