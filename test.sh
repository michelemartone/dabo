#!/bin/bash
VL=0
set -e
test $VL -ge 1 && set -x
PKGS='librsb intel cmake false true'
EMAIL="noreply@organization.tld"
#EMAIL=
PASS=
FAIL=
rm -f *.html *.log *.shar
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
	#mailx -s test-batch-${PKG}:${TR} -a ${LF} -S from=${EMAIL} ${EMAIL}
	FL="test.sh `find -name '*.c' -o -iname '*.h' -o -iname '*.F90'`"
	test $VL -ge 1 && ls -l $FL 
	for TF in $FL ; do
		HS=${SD}.html # HS=$TF.html
		HOME=. vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w! $HS" -c 'qall!' 2>&1 > $DN
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
BODY=
test -n "$FAIL" && BODY+="FAIL: $FAIL. \n"
test -n "$PASS" && BODY+="PASS: $PASS. \n"
CMT=
test -z "$FAIL" && test -n "$PASS" && CMT+="All tests passed."
test -n "$FAIL" && test -z "$PASS" && CMT+="All tests failed."
test -n "$FAIL" && test -n "$PASS" && CMT+="Some tests failed."
pwd
test -n "$FAIL" && for t in $FAIL ; do for f in $t.{log,html} ; do mv $f failed-$f ; done; done
test -n "$PASS" && for t in $PASS ; do for f in $t.{log,html} ; do mv $f passed-$f ; done; done
ls *.html *.log | sort | sed 's/\(.*$\)/<a href="\1">\1<\/a>\n<br\/>/g' > index.html
#SL="${FAIL:+FAIL:}${FAIL} ${PASS:+PASS:}${PASS}"
SL="$CMT"
WD=`basename $PWD`
cd ..
shar $WD/*.log $WD/*.html > $WD/$WD.shar
cd -
ls -l $WD.shar
test -z "$FAIL" && test -z "$PASS" && SL="$SL All test passed."
test -n "$FAIL" || test -n "$PASS" && test -n "$EMAIL" && \
	echo "Mailed to $EMAIL: " "$SL" && \
	echo -e "$BODY" | mailx -s "test-batch: $SL" -S from=${EMAIL} -a $WD.shar ${EMAIL}
