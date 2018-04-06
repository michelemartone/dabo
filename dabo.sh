#!/bin/bash
DN=/dev/null
set -e
test "`uname`" = Linux # not tested elsewhere
EMAIL=${DABO_EMAIL:=""}
test -z "$EMAIL" && echo "INFO: DABO_EMAIL unset -- no report email will be sent."
test "$EMAIL" = "${EMAIL/%@*/@}${EMAIL/#*@/}" || { echo "ERROR: DABO_EMAIL=$DABO_EMAIL : invalid email address!"; false; }
test -n "$EMAIL" && echo "INFO: DABO_EMAIL=$DABO_EMAIL : will send a report email."
test -z "$DABO_VERBOSITY" && echo "INFO: DABO_VERBOSITY unset -- will operate quietly (as with 0)."
VL=${DABO_VERBOSITY:="0"}
[[ "$VL" =~ ^[0123]$ ]] || { echo "ERROR: DABO_VERBOSITY=$DABO_VERBOSITY : 0 to 3!"; false; }
TO=4s;
test -z "$DABO_TIMEOUT" && echo "INFO: DABO_TIMEOUT unset -- will use default test timeout of $TO."
test -n "$DABO_TIMEOUT" && echo "INFO: DABO_TIMEOUT=${DABO_TIMEOUT}: each test will be run with this timeout."
TO=${DABO_TIMEOUT:="$TO"}
[[ "$TO" =~ ^[0-9]+[ms]$ ]] || { echo "ERROR: DABO_TIMEOUT=$DABO_TIMEOUT: <number>[ms], e.g. $TO, 1m, ..!"; false; }
if test "$VL" -ge 1 ; then VMD=-v; VS=''; VCP=-v; else VMD=''; VS=-q; VCP=''; fi
if declare -f module 2>&1 > $DN ; then
	ML="`module list -t`"
	for MN in ${ML} ; do 
		if [[ "$MN" =~ $USER ]] ; then 
			echo "INFO: unload module $MN" ;
			module unload $MN;
		fi
	done
	for MP in ${MODULEPATH//:/ } ; do 
		if [[ "$MP" =~ $USER ]] ; then 
			echo "INFO: unuse path $MP" ;
			module unuse $MP; module unuse $MP; # yes, twice
		fi
	done
fi
test "$VL" -ge 3 && set -x
if echo $MODULEPATH | grep $USER; then echo "ERROR: shall unload personal modules first!"; false; fi
TSTS='false true example_pass self timeout'
PASS=''
FAIL=''
POFL=''
FOFL=''
PDIR=`pwd`/
MPIF='/etc/profile.d/modules.sh' # module path include file
if ! declare -f module > /dev/null -a -r "$MPIF"; then echo "INFO: activating module system by including $MPIF"; . $MPIF; fi
test -z "$DABO_RESULTS_DIR" && echo "INFO: DABO_RESULTS_DIR unset -- will use working directory: $PDIR"
PDIR=${DABO_RESULTS_DIR:="$PDIR"}
test "${PDIR:0:1}" = '/' || { echo "ERROR: DABO_RESULTS_DIR=$DABO_RESULTS_DIR: not an absolute path ..!"; false; }
[[ "$PDIR" =~ /$ ]] || PDIR+='/'
mkdir -p ${VMD} -- "$PDIR"
test -d "$PDIR"
rm -f -- $PDIR/*.shar
export DABO_SCRIPT="`which $0`" 
for TST in ${@:-$TSTS} ; do
	if   test -d "$TST" -a "${TST:0:1}" = '/'; then
		echo "ERROR: $TST is not a relative path!";
		false
		TS=$TST/test.sh
		PD=''
		DP=$TST
	elif test -d "$TST" -a "${TST:0:1}" = '.'; then
		TS=`pwd`/$TST/test.sh
		PD=$PDIR
		DP=$TST
		test "$VL" -ge 1 && echo "INFO: Will write logs to $PD$DP"
	elif test ! -d "$TST" ; then
		echo "ERROR: $TST is not a directory!";
		false
	else
		TS=`pwd`/$TST/test.sh
		PD=$PDIR
		DP=$TST # relative
		test "$VL" -ge 1 && echo "INFO: Will write logs to $PD$DP"
	fi
	test -d "$TST" -a "${TS:0:1}" = '/'
	TBN=${TST//[.\/]/_}
	while test "$TBN" != "${TBN/#_/}"; do TBN=${TBN/#_/}; done
	test -n "$TBN"
	[[ "$TBN" =~ ^[._[:alnum:]-]*$ ]] || { echo "ERROR: only alphanumeric and _ in test names, please (not $TBN)."; false; }
	LP=$DP/test.sh.log
	LF=$PD$LP
	test -f $TS
	TD=`mktemp -d /dev/shm/$TBN-XXXX`
	test -d $TD
	IFL=""
	{ for f in $TST/*.shar $TST/test.sh ; do test -f $f && cp ${VCP} -- $f $TD && IFL="$IFL `basename $f`" ; done || true ; } > $DN
	cp ${VCP} -- $TS $TD
	cd $TD
	mkdir -p ${VMD} -- `dirname $LF`
	( timeout $TO bash --norc -e $TS 2>&1 ; ) 1> $LF \
		&& {        TR="pass"; echo "PASS TEST: $TST"; PASS+=" $TBN"; } \
		|| { TC=$?; TR="fail"; echo "FAIL TEST: $TST`test $TC == 124 && echo ' [TIMEOUT]'`""`echo ' '[LOG: $LF]`"; FAIL+=" $TBN"; }
	#mailx -s test-batch-${TBN}:${TR} -a ${LF} -S from="${EMAIL}" "${EMAIL}"
	SC=dabo.sh # this script basename
	OFL="`find -maxdepth 1 -name test.sh -o -name '*.c' -o -iname '*.h' -o -iname '*.F90'`"
	test "$VL" -ge 1 && ls -l -- $OFL 
	for TF in $OFL ; do
		HS=${DP}/`basename ${TF}`.html
		mkdir -p ${VMD} -- `dirname $PD$HS`
		! HOME=. nohup vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w! ${PD}$HS" -c 'qall!' 2> $DN
		test -f ${PD}${HS}
		#elinks ${PD}${HS}
		test "$TR" = "pass" && POFL="$POFL ${HS}"
		test "$TR" = "fail" && FOFL="$FOFL ${HS}"
	done
	test -f $LF
	test "$TR" = "fail" && test "$VL" -ge 2 && nl $LF
	test "$TR" = "pass" && POFL="$POFL ${LP}"
	test "$TR" = "fail" && FOFL="$FOFL ${LP}"
	test "$TR" = "pass" -a -n "${IFL}" && mkdir -p ${VMD} -- $PD$DP && cp -np ${VCP} -- $IFL $PD$DP
	test "$TR" = "fail" -a -n "${IFL}" && mkdir -p ${VMD} -- $PD$DP && cp -np ${VCP} -- $IFL $PD$DP
	test "$VL" -ge 1 && ls -l
	rm -fR -- $TD
	cd - 2>&1 > $DN
done
FAIL=${FAIL// false/}
BODY=
test -n "$FAIL" && BODY+="FAIL: $FAIL. \n"
test -n "$PASS" && BODY+="PASS: $PASS. \n"
AUTHOR="$USER@$HOSTNAME"
BODY+="\n Generated by $AUTHOR on https://github.com/michelemartone/dabo.\n"
CMT="$HOSTNAME : "
test -z "$FAIL" && test -n "$PASS" && CMT+="All tests passed."
test -n "$FAIL" && test -z "$PASS" && CMT+="All tests failed."
test -n "$FAIL" && test -n "$PASS" && CMT+="Some tests failed."
SL="$CMT"
LOFL=""
LOPL=""
test -n "$FOFL" && for t in $FOFL ; do [[ "$t" =~ \.log ]] && LOFL+=" $t" ; done; 
test -n "$POFL" && for t in $POFL ; do [[ "$t" =~ \.log ]] && LOPL+=" $t" ; done; 
#ls -- *.html *.log | sort | sed 's/\(.*$\)/<a href="\1">\1<\/a>\n<br\/>/g' > index.html
#SL="${FAIL:+FAIL:}${FAIL} ${PASS:+PASS:}${PASS}"
cd $PDIR
FL='' PL=''
test -n "$LOFL" && FL=$PDIR/failed.log && tail -n 10000 $LOFL > $FL
test -n "$LOPL" && PL=$PDIR/passed.log && tail -n 10000 $LOPL > $PL
#IF="test.sh README.md"
IF=''
if test -n "$POFL"; then
	PS=$PDIR/passed.shar; shar ${VS} -T $POFL $IF > $PS ; test -f "$PS"; 
fi
if test -n "$FOFL"; then
	FS=$PDIR/failed.shar; shar ${VS} -T $FOFL $IF > $FS ; test -f "$FS";
fi
cd -
LS=''
WD=`basename $PWD`
if test -f README.md -a -f "$SC" ; then
	LS=`basename $PWD`.shar
	cd ..
	shar ${VS} -T  $WD/README.md $WD/$SC $WD/*/test.sh $WD/*/*.shar > $WD/$LS # FIXME: */test.sh might still fail, if executing from somewhere else.
	test -f "$WD/$LS"
	cd -
fi
#bash   "$PS"
#bash   "$LS"
test -n "$FAIL" && FF=$FS
test -n "$PASS" && PF=$PS
echo "INFO: Give a look at: ${FL} ${PL} ${FF} ${PF} ${LS}"
test -z "$FAIL" && FF=''
test -z "$PASS" && PF=''
test -z "$FAIL" && test -z "$PASS" && SL="$SL All test passed."
if test -n "$EMAIL" ; then
	test -n "$FAIL" || test -n "$PASS" && \
	echo "INFO: Mailed to ${AUTHOR} <$EMAIL>: " "$SL" && \
	echo -e "$BODY" | mailx -s "test-batch: $SL" -S from="${AUTHOR//@/-at-} <${EMAIL}>" ${FL:+-a }${FL} ${PL:+-a }${PL} ${FF:+-a }${FF} ${PF:+-a }${PF} ${LS:+-a }${LS} "${EMAIL}";
fi