#!/bin/bash
set -e
module help gcc
module show gcc
module load gcc
set -x
gcc -dumpmachine
gcc -v
