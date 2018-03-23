#!/bin/bash
set -e
set -x
for PKG in librsb ; do
	test -d $PKG
	TS=`pwd`/$PKG/test.sh
	test -f $TS
	TD=`mktemp -d /dev/shm/$PKG-XXXX`
	test -d $TD
	cd $TD
	bash $TS && echo SUCCESS || echo FAILURE
	rm -fR $TD
	cd -
done
