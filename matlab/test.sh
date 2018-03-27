#!/bin/bash
set -e
module help matlab
module show matlab
module load matlab
set -x
which matlab
ldd matlab
MO=`matlab -nojvm -nodesktop  -nodisplay  -r '3*4,quit' -nosplash | grep ans -A 2`
echo  ${MO}
test "${MO}" = "ans =

    12"
