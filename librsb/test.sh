#!/bin/bash
#test "`basename $0`" = "$0"
set -e
module use -a /lrz/sys/share/modules/extfiles
module show librsb/1.2.0-rc7_gcc6
module help librsb/1.2.0-rc7_gcc6
module load librsb/1.2.0-rc7_gcc6
set -x
EXD=`dirname $LIBRSB_CONFIG`/../share/doc/librsb/examples # TODO: need e.g. EXAMPLE_DIR 
cp -pv $EXD/hello.c .
cat           hello.c
$LIBRSB_CC -c hello.c       `$LIBRSB_CONFIG --I_opts`
$LIBRSB_CC -o hello hello.o `$LIBRSB_CONFIG --static --ldflags --extra_libs`
./hello
set +x
