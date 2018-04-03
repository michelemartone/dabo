#!/bin/bash
set -e
test "$LRZ_SYSTEM_SEGMENT" = CMUC2
for MP in ${MODULEPATH//:/ } ; do 
	if [[ "$MP" =~ $USER ]] ; then 
		module unuse $MP; echo "unloading module $MP" 
	fi
done
#PML=`module avail petsc | grep -v -- --`
PML="petsc/3.8"
#PML="petsc/3.8 petsc/3.8_debug petsc/3.8c petsc/3.8c_debug"
#PML=petsc/3.8 petsc/3.8-mumps petsc/3.8_debug petsc/3.8_debug-mumps petsc/3.8c petsc/3.8c_debug
for LM in $PML ; do
	echo Using: $LM
	module show $LM
	module help $LM
	module load $LM
	test -n "$PETSC_CMD_TEST"
	eval "$PETSC_CMD_TEST"
	module unload $LM
done
echo "Done"
