#!/bin/bash
DN=/dev/null
set -e
test "`uname`" = Linux # not tested elsewhere
OPTSTRING="e:s:v:t:d:o:"
while getopts $OPTSTRING NAME; do
	case $NAME in
		e) DABO_EMAIL=$OPTARG;;
		s) DABO_SUBJPFX=$OPTARG;;
		v) DABO_VERBOSITY=$OPTARG;;
		t) DABO_TIMEOUT=$OPTARG;;
		o|d) DABO_RESULTS_DIR=$OPTARG;;
		*) false
	esac
done
shift $((OPTIND-1))
EMAIL=${DABO_EMAIL:=""}
test -z "$EMAIL" && echo "INFO: DABO_EMAIL [-e] unset -- no report email will be sent."
test "$EMAIL" = "${EMAIL/%@*/@}${EMAIL/#*@/}" || { echo "ERROR: DABO_EMAIL=$DABO_EMAIL : invalid email address!"; false; }
test -n "$EMAIL" && echo "INFO: DABO_EMAIL=$DABO_EMAIL : will send a report email."
test -z "$DABO_VERBOSITY" && echo "INFO: DABO_VERBOSITY [-v] unset -- will operate quietly (as with 0)."
VL=${DABO_VERBOSITY:="0"}
[[ "$VL" =~ ^[0123]$ ]] || { echo "ERROR: DABO_VERBOSITY=$DABO_VERBOSITY : 0 to 3!"; false; }
TO=4s;
test -z "$DABO_TIMEOUT" && echo "INFO: DABO_TIMEOUT [-t] unset -- will use default test timeout of $TO."
test -n "$DABO_TIMEOUT" && echo "INFO: DABO_TIMEOUT=${DABO_TIMEOUT}: each test will be run with this timeout."
TO=${DABO_TIMEOUT:="$TO"}
[[ "$TO" =~ ^[0-9]+[ms]$ ]] || { echo "ERROR: DABO_TIMEOUT=$DABO_TIMEOUT: <number>[ms], e.g. $TO, 1m, ..!"; false; }
DSP="TEST: "
test -z "$DABO_SUBJPFX" && echo "INFO: DABO_SUBJPFX [-s] unset -- will use default email subject prefix \"$DSP\"."
test -n "$DABO_SUBJPFX" && echo "INFO: DABO_SUBJPFX=${DABO_SUBJPFX}: user-set email subject prefix."
DSP=${DABO_SUBJPFX:="$DSP"} # default subject prefix
if test "$VL" -ge 1 ; then VMD=-v; VS=''; VCP=-v; VTAR=v; else VMD=''; VS=-q; VCP=''; VTAR=''; fi
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
TSTS=''
TSTS=${TSTS:="$@"}
ECT="'mkdir mytest; echo true  > mytest/test.sh; $0 mytest;'"
ECF="'mkdir mytest; echo false > mytest/test.sh; $0 mytest;'"
EI="You can create your own first test case easily, e.g.: $ECT or $ECF."
UI="Each test directory contains one script file called 'test.sh', and shall be specified with its relative path."
PASS=''
FAIL=''
POFL=''
FOFL=''
CHEAPTOHTMLRE='s/$/<br>/g'
PDIR=`pwd`/
test -z "$DABO_RESULTS_DIR" && echo "INFO: DABO_RESULTS_DIR [-d/-o] unset -- will use working directory: $PDIR"
PDIR=${DABO_RESULTS_DIR:="$PDIR"}
test "${PDIR:0:1}" = '/' || { echo "ERROR: DABO_RESULTS_DIR=$DABO_RESULTS_DIR: not an absolute path ..!"; false; }
[[ "$PDIR" =~ /$ ]] || PDIR+='/'
MPIF='/etc/profile.d/modules.sh' # module path include file
if test -r "$MPIF" && ! declare -f module > /dev/null ; then echo "INFO: activating module system by including $MPIF"; . $MPIF; fi
if test -z "$TSTS"; then echo "INFO: No test directory specified at the command line -- exiting. $UI $EI"; exit ; fi
mkdir -p ${VMD} -- "$PDIR"
test -d "$PDIR"
rm -f -- $PDIR/*.shar
export DABO_SCRIPT="`which $0`" 
for TST in ${TSTS} ; do
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
#	elif test ! -d "$TST" ; then
#		echo "ERROR: $TST is not a directory! $UI";
#		false
	elif test ! -d "$TST" ; then
		echo "INFO: $TST is not a test directory -- SKIPPING! $UI";
		continue;
	else
		TS=`pwd`/$TST/test.sh
		PD=$PDIR
		DP=$TST # relative
		test "$VL" -ge 1 && echo "INFO: Will write logs to $PD$DP"
	fi
	test ! -f $TS && { echo "INFO: $TS is not present -- SKIPPING test \"$TST\""; continue; }
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
	cd $TD/..
	TTBN=`basename $TD` # test tarball name
	TTB=${DABO_RESULTS_DIR}/$TTBN.tar.gz
	tar c${VTAR}zf ${TTB} --transform s/${TTBN}/${TBN}/g --show-transformed-names ${TTBN}
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
		! HOME=. vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w! ${PD}$HS" -c 'qall!' 2>&1 > $DN
		test -f ${PD}${HS}
		if cmp $TF ${PD}${HS} > $DN ; then echo "WARNING: $TF -> ${PD}${HS} conversion failed"; sed -i "$CHEAPTOHTMLRE" ${PD}${HS}; true; fi # e.g. nohup vim
		#elinks ${PD}${HS}
		test "$TR" = "pass" && POFL="$POFL ${HS}"
		test "$TR" = "fail" && FOFL="$FOFL ${HS}"
	done
	test -f $LF
	cp $LF $LF.html && sed -i 's/$/<br>/g' $LF.html
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
BODY+="\n Generated by $AUTHOR on https://github.com/michelemartone/dabo\n"
CMT="$HOSTNAME : "
words_count() { echo ${#@}; }
PC=`words_count $PASS`
FC=`words_count $FAIL`
TC=`words_count $PASS $FAIL`
test -z "$FAIL" && test -n "$PASS" && CMT+="All tests passed [$PC/$TC]."
test -n "$FAIL" && test -z "$PASS" && CMT+="All tests failed [$FC/$TC]."
test -n "$FAIL" && test -n "$PASS" && CMT+="Some tests failed [$FC/$TC]."
SL="$CMT"
LOFL=""
LOPL=""
test -n "$FOFL" && for t in $FOFL ; do [[ "$t" =~ \.log ]] && LOFL+=" $t" ; done; 
test -n "$POFL" && for t in $POFL ; do [[ "$t" =~ \.log ]] && LOPL+=" $t" ; done; 
#ls -- *.html *.log | sort | sed 's/\(.*$\)/<a href="\1">\1<\/a>\n<br\/>/g' > index.html
#SL="${FAIL:+FAIL:}${FAIL} ${PASS:+PASS:}${PASS}"
cd $PDIR
FL='' PL=''
TSL="-`date +%s`"
test -n "$LOFL" && FL=$PDIR/failed${TSL}.log && tail -n 10000 $LOFL > $FL
test -n "$LOPL" && PL=$PDIR/passed${TSL}.log && tail -n 10000 $LOPL > $PL
#IF="test.sh README.md"
IF=''
if test -n "$POFL"; then
	PS=$PDIR/passed${TSL}.shar; shar ${VS} -T $POFL $IF > $PS ; test -f "$PS"; 
fi
if test -n "$FOFL"; then
	FS=$PDIR/failed${TSL}.shar; shar ${VS} -T $FOFL $IF > $FS ; test -f "$FS";
fi
cd - > $DN
LS='' # devel-side sources archive
#WD=`basename $PWD`
#if test -f README.md -a -f "$SC" ; then
#	LS=`basename $PWD`.shar
#	cd ..
#	SFL=`for f in $WD/README.md $WD/$SC $WD/*/test.sh $WD/*/*.shar; do if test -f $f ;then echo $f; fi ; done` 
#	if test -z "$SFL"; then LS=''; else 
#		shar ${VS} -T $SFL > $WD/$LS # FIXME: */test.sh might still fail, if executing from somewhere else.
#		test -f "$WD/$LS"
#	fi
#	cd - > $DN
#fi
test -n "$FAIL" && FF=$FS
test -n "$PASS" && PF=$PS
echo "INFO: Give a look at: ${FL} ${PL} ${FF} ${PF} ${LS}"
test -z "$FAIL" && FF=''
test -z "$PASS" && PF=''
test -z "$FAIL" && test -z "$PASS" && SL="$SL All test passed."
if test -n "$EMAIL" ; then
	test -n "$FAIL" || test -n "$PASS" && \
	echo "INFO: Mailed to \"${AUTHOR} <$EMAIL>\" with subject \"$SL\"" && \
	echo -e "$BODY" | mailx -s "$DSP$SL" -S from="${AUTHOR//@/-at-} <${EMAIL}>" ${FL:+-a }${FL} ${PL:+-a }${PL} ${FF:+-a }${FF} ${PF:+-a }${PF} ${LS:+-a }${LS} "${EMAIL}";
fi
