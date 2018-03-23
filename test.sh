#!/bin/bash
set -e
set -x
for PKG in librsb ; do
	test -d $PKG
	TS=`pwd`/$PKG/test.sh
	LF=`pwd`/$PKG.log
	test -f $TS
	TD=`mktemp -d /dev/shm/$PKG-XXXX`
	test -d $TD
	cd $TD
	bash $TS 2>&1 1> $LF && echo SUCCESS || echo FAILURE
	HS=$TD/`basename $TS`.html
	HOME=. vim -E $TS -c 'syntax on' -c 'TOhtml' -c "w $HS" -c 'qall!'
	test -f $HS
	ls -l
	# elinks $HS
	# cp $HS ~/
	rm -fR $TD
	test -f $LF
	#nl $LF
	cd -
done
