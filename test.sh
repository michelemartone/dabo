#!/bin/bash
set -e
EMAIL=${EMAIL:="noreply@organization.tld"}
VL=${VL:="0"}
test "$VL" -ge 1 && set -x
PKGS='false true filesystems gcc intel git svn cmake librsb octave lrztools matlab spack python-3.0.1 gromacs'
PASS=''
FAIL=''
rm -f -- *.html *.log *.shar
for PKG in ${@:-$PKGS} ; do
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
	( timeout 4s bash -e $TS 2>&1 ; ) 1> $LF \
		&& { TR="pass"; echo "PASS: $PKG"; PASS+=" $PKG"; } \
		|| { TR="fail"; echo "FAIL: $PKG"; FAIL+=" $PKG"; }
	#mailx -s test-batch-${PKG}:${TR} -a ${LF} -S from="${EMAIL}" "${EMAIL}"
	FL="test.sh `find -maxdepth 1 -name '*.c' -o -iname '*.h' -o -iname '*.F90'`"
	test "$VL" -ge 1 && ls -l -- $FL 
	for TF in $FL ; do
		HS=${SD}-`basename ${TF}`.html # HS=$TF.html
		HOME=. vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w! $HS" -c 'qall!' 2>&1 > $DN
		test -f $HS
		#elinks $HS
	done
	test "$VL" -ge 1 && ls -l
	rm -fR -- $TD
	test -f $LF
	test "$VL" -ge 2 && nl $LF
	cd - 2>&1 > $DN
done
FAIL=${FAIL// false/}
echo
BODY=
test -n "$FAIL" && BODY+="FAIL: $FAIL. \n"
test -n "$PASS" && BODY+="PASS: $PASS. \n"
CMT="$HOSTNAME : "
test -z "$FAIL" && test -n "$PASS" && CMT+="All tests passed."
test -n "$FAIL" && test -z "$PASS" && CMT+="All tests failed."
test -n "$FAIL" && test -n "$PASS" && CMT+="Some tests failed."
pwd
test -n "$FAIL" && for t in $FAIL ; do for f in $t*.{log,html} ; do mv $f failed-$f ; done; done
test -n "$PASS" && for t in $PASS ; do for f in $t*.{log,html} ; do mv $f passed-$f ; done; done
ls -- *.html *.log | sort | sed 's/\(.*$\)/<a href="\1">\1<\/a>\n<br\/>/g' > index.html
#SL="${FAIL:+FAIL:}${FAIL} ${PASS:+PASS:}${PASS}"
SL="$CMT"
WD=`basename $PWD`
PS=`basename $PWD`-passed.shar
shar -q -T passed*.log passed*.html \
	README.md `find $PASS -maxdepth 1 -name 'test.sh' -or -name '*.shar'` \
	> $PS
test -f "$PS"
ls -l   "$PS"
LS=`basename $PWD`.shar
cd ..
shar -q -T $WD/*.log $WD/*.html \
	$WD/README.md $WD/test.sh $WD/*/test.sh $WD/*/*.shar \
	> $WD/$LS
test -f "$WD/$LS"
cd -
test -n "$FAIL" && FF=failed-all.log && tail -n 10000 failed-*.log > $FF
test -n "$PASS" && PF=$PS
test -z "$FAIL" && FF=''
test -z "$PASS" && PF=''
test -z "$FAIL" && test -z "$PASS" && SL="$SL All test passed."
test -n "$FAIL" || test -n "$PASS" && test -n "$EMAIL" && \
	echo "Mailed to $EMAIL: " "$SL" && \
	echo -e "$BODY" | mailx -s "test-batch: $SL" -S from=${EMAIL} -a $LS ${FF:+-a} ${FF} ${PF:+-a} ${PF} "${EMAIL}"
