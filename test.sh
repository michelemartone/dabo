#!/bin/bash
set -e
set -x
PKGS='librsb intel cmake'
for PKG in ${1:-$PKGS} ; do
	test -d $PKG
	SD=`pwd`/$PKG
	TS=`pwd`/$PKG/test.sh
	LF=`pwd`/$PKG.log
	test -f $TS
	TD=`mktemp -d /dev/shm/$PKG-XXXX`
	test -d $TD
	cd $TD
	for f in $SD/*.shar ; do cp $f . ; done || true
	cp $TS .
	bash $TS 2>&1 1> $LF && echo SUCCESS || echo FAILURE
	FL="test.sh `find -name '*.c' -o -iname '*.h' -o -iname '*.F90'`"
	ls -l $FL 
	for TF in $FL ; do
		HS=$TF.html
		HOME=. vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w $HS" -c 'qall!'
		test -f $HS
		#elinks $HS
	done
	ls -l
	rm -fR $TD
	test -f $LF
	nl $LF
	cd -
done
echo ALL SUCCESS
