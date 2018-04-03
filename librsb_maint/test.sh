#!/bin/bash
set -e
test "$LRZ_SYSTEM_SEGMENT" = CMUC2
module use -a /lrz/sys/share/modules/extfiles/
for MP in ${MODULEPATH//:/ } ; do 
	if [[ "$MP" =~ $USER ]] ; then 
		module unuse $MP; echo "unloading module $MP" 
	fi
done
LML=`module avail librsb | grep -v -- --`
echo Found: $LML
for LM in $LML ; do
	echo Using: $LM
	module show $LM
	module help $LM
	module load $LM
	set -x
	test -n "$LIBRSB_CONFIG"
	test -f "$LIBRSB_CONFIG"
	test -x "$LIBRSB_CONFIG"
	EXD=`dirname $LIBRSB_CONFIG`/../share/doc/librsb/examples # TODO: need e.g. LIBRSB_EXAMPLE_DIR 
	test -n "$EXD"
	test -d "$EXD"
	cp -pv $EXD/hello.c .
	test -f       hello.c
	ls -l         hello.c
	#cat           hello.c
	test -n $LIBRSB_CC
	test -f $LIBRSB_CC
	test -x $LIBRSB_CC
	$LIBRSB_CC -c hello.c       `$LIBRSB_CONFIG --I_opts`
	$LIBRSB_CC -o hello hello.o `$LIBRSB_CONFIG --static --ldflags --extra_libs`
	test -f ./hello
	test -x ./hello
	./hello
	rm ./hello
	set +x
	module unload $LM
done
module unuse /lrz/sys/share/modules/extfiles/
echo "Done"
