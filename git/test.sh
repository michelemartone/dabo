#!/bin/bash
set -e
module help git
module show git
module load git
set -x
which git
git help ls
git --version
