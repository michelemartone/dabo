#!/bin/bash
set -e
set -x
test "$LRZ_SYSTEM_SEGMENT" = CMUC3
test -z "$MUMPS_BASE"
set +x
module load mkl
module load metis
module load scalapack
module show mumps/5.0.1
# module help mumps/5.0.1
module load mumps/5.0.1
set -x
test -n "$MUMPS_BASE"
test -d "$MUMPS_BASE"
test ! -f "$MUMPS_BASE"
#
test -n "$MUMPS_LIBDIR"
test -d "$MUMPS_LIBDIR"
test ! -f "$MUMPS_LIBDIR"
set +x
module unload mumps/5.0.1
echo Done
