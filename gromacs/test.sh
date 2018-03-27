#!/bin/bash
set -e
module help gromacs
module show gromacs
module load gromacs
set -x
gmx --version
