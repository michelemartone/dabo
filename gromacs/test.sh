#!/bin/bash
module unload gcc
set -e
module help gromacs
module show gromacs
module load gromacs
set -x
gmx --version
