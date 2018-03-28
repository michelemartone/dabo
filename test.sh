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
TSTS='false true filesystems gcc intel git svn cmake librsb octave lrztools matlab spack python-3.0.1 gromacs timeout'
PASS=''
FAIL=''
POFL=''
FOFL=''
rm -f -- *.shar
for TST in ${@:-$TSTS} ; do
	if   test -d "$TST" -a "${TST:0:1}" = '/'; then
		echo "Error: $TST is not a local directory!";
		false
		TS=$TST/test.sh
		DP=$TST
		PD=''
	elif test -d "$TST" -a "${TST:0:1}" = '.'; then
		TS=`pwd`/$TST/test.sh
		DP=`pwd`/$TST
		PD=''
	elif test ! -d "$TST" ; then
		echo "Error: $TST is not a directory!";
		false
	else
		TS=`pwd`/$TST/test.sh
		DP=$TST # relative
		PD=`pwd`/
	fi
	test -d "$TST" -a "${TS:0:1}" = '/'
	TBN=${TST//[.\/]/_}
	while test "$TBN" != "${TBN/#_/}"; do TBN=${TBN/#_/}; done
	test -n "$TBN"
	[[ "$TBN" =~ ^[._[:alnum:]-]*$ ]] || { echo "Error: only alphanumeric and _ in test names, please (not $TBN)."; false; }
	LP=$DP/test.sh.log
	LF=$PD$LP
	test -f $TS
	TD=`mktemp -d /dev/shm/$TBN-XXXX`
	DN=/dev/null
	test -d $TD
	IFL=""
	{ for f in $TST/*.shar $TST/test.sh ; do test -f $f && cp $f $TD && IFL="$IFL `basename $f`" ; done || true ; } > $DN
	cp $TS $TD
	cd $TD
	( timeout $TO bash -e $TS 2>&1 ; ) 1> $LF \
		&& { TR="pass"; echo "PASS: $TST"; PASS+=" $TBN"; } \
		|| { TR="fail"; echo "FAIL: $TST"; FAIL+=" $TBN"; }
	#mailx -s test-batch-${TBN}:${TR} -a ${LF} -S from="${EMAIL}" "${EMAIL}"
	OFL="`find -maxdepth 1 -name test.sh -o -name '*.c' -o -iname '*.h' -o -iname '*.F90'`"
	test "$VL" -ge 1 && ls -l -- $OFL 
	for TF in $OFL ; do
		HS=${DP}/`basename ${TF}`.html
		HOME=. vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w! ${PD}$HS" -c 'qall!' 2>&1 > $DN
		test -f ${PD}${HS}
		#elinks ${PD}${HS}
		test "$TR" = "pass" && POFL="$POFL ${HS}"
		test "$TR" = "fail" && FOFL="$FOFL ${HS}"
	done
	test -f $LF
	test "$VL" -ge 2 && nl $LF
	test "$TR" = "pass" && POFL="$POFL ${LP}"
	test "$TR" = "fail" && FOFL="$FOFL ${LP}"
	test "$TR" = "pass" -a -n "${IFL}" && cp -npv $IFL $PD$DP
	test "$TR" = "fail" -a -n "${IFL}" && cp -npv $IFL $PD$DP
	test "$VL" -ge 1 && ls -l
	rm -fR -- $TD
	cd - 2>&1 > $DN
done
FAIL=${FAIL// false/}
BODY=
test -n "$FAIL" && BODY+="FAIL: $FAIL. \n"
test -n "$PASS" && BODY+="PASS: $PASS. \n"
CMT="$HOSTNAME : "
test -z "$FAIL" && test -n "$PASS" && CMT+="All tests passed."
test -n "$FAIL" && test -z "$PASS" && CMT+="All tests failed."
test -n "$FAIL" && test -n "$PASS" && CMT+="Some tests failed."
#test -n "$FAIL" && for t in $FAIL ; do for f in $t*.{log,html} ; do mv $f failed-$f ; done; done
#test -n "$PASS" && for t in $PASS ; do for f in $t*.{log,html} ; do mv $f passed-$f ; done; done
#ls -- *.html *.log | sort | sed 's/\(.*$\)/<a href="\1">\1<\/a>\n<br\/>/g' > index.html
#SL="${FAIL:+FAIL:}${FAIL} ${PASS:+PASS:}${PASS}"
IF="test.sh README.md"
SL="$CMT"
WD=`basename $PWD`
PS=`basename $PWD`-passed.shar
shar -q -T $POFL $IF > $PS
test -f "$PS"
ls -l   "$PS"
FS=`basename $PWD`-failed.shar
shar -q -T $FOFL $IF > $FS
test -f "$FS"
ls -l   "$FS"
LS=`basename $PWD`.shar
cd ..
shar -q -T  \
	$WD/README.md $WD/test.sh $WD/*/test.sh $WD/*/*.shar \
	> $WD/$LS
test -f "$WD/$LS"
ls -l   "$WD/$LS"
cd -
#bash   "$PS"
#bash   "$LS"
#test -n "$FAIL" && FF=failed-all.log && tail -n 10000 failed-*.log > $FF
test -n "$FAIL" && FF=$FS
test -n "$PASS" && PF=$PS
test -z "$FAIL" && FF=''
test -z "$PASS" && PF=''
test -z "$FAIL" && test -z "$PASS" && SL="$SL All test passed."
if test -n "$EMAIL" ; then
	test -n "$FAIL" || test -n "$PASS" && \
	echo "Mailed to $EMAIL: " "$SL" && \
	echo -e "$BODY" | mailx -s "test-batch: $SL" -S from=${EMAIL} -a $LS ${FF:+-a} ${FF} ${PF:+-a} ${PF} "${EMAIL}";
fi
