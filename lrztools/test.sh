#!/bin/bash
set -e
module help lrztools
module show lrztools
module load lrztools
set -x
test -d $LRZTOOLS_BASE
test -d $LRZTOOLS_BASE/bin
ls -l   $LRZTOOLS_BASE/bin
energy
# many more ...
