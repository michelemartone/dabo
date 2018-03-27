#!/bin/bash
set -e
module help octave
module show octave
module load octave
set -x
OO=`octave --no-site-file --norc --no-gui --eval '3+1'`
test "${OO}" = "ans =  4"
