#!/bin/bash
VL=0
set -e
test $VL -ge 1 && set -x
PKGS='librsb intel cmake'
PASS=
FAIL=
for PKG in ${1:-$PKGS} ; do
	test -d $PKG
	SD=`pwd`/$PKG
	TS=`pwd`/$PKG/test.sh
	LF=`pwd`/$PKG.log
	test -f $TS
	TD=`mktemp -d /dev/shm/$PKG-XXXX`
	DN=/dev/null
	test -d $TD
	cd $TD
	( for f in $SD/*.shar ; do test -f $f && cp $f . ; done || true ; ) > $DN
	cp $TS .
	( bash -e $TS 2>&1 ; ) 1> $LF \
		&& { echo "PASS: $PKG";  PASS+=" $PKG"; } \
		|| { echo "FAIL: $PKG"; FAIL+=" $PKG"; }
	FL="test.sh `find -name '*.c' -o -iname '*.h' -o -iname '*.F90'`"
	test $VL -ge 1 && ls -l $FL 
	for TF in $FL ; do
		HS=$TF.html
		HOME=. vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w $HS" -c 'qall!' 2>&1 > $DN
		test -f $HS
		#elinks $HS
	done
	test $VL -ge 1 && ls -l
	rm -fR $TD
	test -f $LF
	test $VL -ge 2 && nl $LF
	cd - 2>&1 > $DN
done
echo
test -n "$FAIL" && echo "FAIL: $FAIL"
test -n "$PASS" && echo "PASS: $PASS"
test -z "$FAIL" && test -n "$PASS" && echo "All tests passed."
test -n "$FAIL" && test -z "$PASS" && echo "All tests failed."
