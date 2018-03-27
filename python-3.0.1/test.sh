#!/bin/bash
set -e
module help python/3.0.1
module show python/3.0.1
module load python/3.0.1
set -x
python3.0 --version
# wget $PYTHON_DOC # URL ?
# test -d $PYTHON_DOC # DIR ? 
