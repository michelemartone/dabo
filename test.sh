#!/bin/bash
set -e
EMAIL=${SCAMC_EMAIL:=""}
test -z "$EMAIL" && echo "SCAMC_EMAIL unset -- no report email will be sent."
test "$EMAIL" = "${EMAIL/%@*/@}${EMAIL/#*@/}" || { echo "Error: SCAMC_EMAIL=$SCAMC_EMAIL : invalid email address!"; false; }
test -n "$EMAIL" && echo "SCAMC_EMAIL=$SCAMC_EMAIL : will send a report email."
VL=${SCAMC_VERBOSITY:="0"}
[[ "$VL" =~ ^[012]$ ]] || { echo "Error: SCAMC_VERBOSITY=$SCAMC_VERBOSITY : 0, 1 or 2!"; false; }
TO=${SCAMC_TIMEOUT:="4s"}
[[ "$TO" =~ ^[0-9]+[ms]$ ]] || { echo "Error: SCAMC_TIMEOUT=$SCAMC_TIMEOUT: <number>[ms], e.g. 4s, 1m, ..!"; false; }
test "$VL" -ge 1 && set -x
TSTS='false true filesystems gcc intel git svn cmake librsb octave lrztools matlab spack python-3.0.1 gromacs'
PASS=''
FAIL=''
rm -f -- *.html *.log *.shar
for TST in ${@:-$TSTS} ; do
	if test -d $TST; then
		test ${TST:0:1} = '/' && { echo "Error: $TST must be a local directory!"; false; }
	else
		echo "Error: $TST is not a directory!";
		false
	fi
	SD=`pwd`/$TST
	TS=`pwd`/$TST/test.sh
	LF=`pwd`/$TST.log
	test -f $TS
	TD=`mktemp -d /dev/shm/$TST-XXXX`
	DN=/dev/null
	test -d $TD
	cd $TD
	( for f in $SD/*.shar ; do test -f $f && cp $f . ; done || true ; ) > $DN
	cp $TS .
	( timeout $TO bash -e $TS 2>&1 ; ) 1> $LF \
		&& { TR="pass"; echo "PASS: $TST"; PASS+=" $TST"; } \
		|| { TR="fail"; echo "FAIL: $TST"; FAIL+=" $TST"; }
	#mailx -s test-batch-${TST}:${TR} -a ${LF} -S from="${EMAIL}" "${EMAIL}"
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
if test -n "$EMAIL" ; then
	test -n "$FAIL" || test -n "$PASS" && \
	echo "Mailed to $EMAIL: " "$SL" && \
	echo -e "$BODY" | mailx -s "test-batch: $SL" -S from=${EMAIL} -a $LS ${FF:+-a} ${FF} ${PF:+-a} ${PF} "${EMAIL}";
fi
