#!/bin/bash
DABO_HELP='
Usage:

    dabo.sh <option switches> <test-case> # note: option switches first

A test-case is either a directory containing a test.sh file or a 
prefixed script path like <test-dir>/test.sh.
That test script will be copied to a temporary directory and executed.
If it returns zero the test passes, otherwise it fails.

Check it out:

    mkdir -p echo_test; echo "echo my echo test;false" > echo_test/test.sh 
    ./dabo.sh -L echo_test  # fails
    mkdir -p echo_test; echo "echo my echo test;true " > echo_test/test.sh 
    ./dabo.sh -L echo_test  # passes

Environment variables:

    DABO_EMAIL       # if set, send report to this email address.
    DABO_SUBJPFX     # if set, email subject prefix
    DABO_VERBOSITY   # print verbosity: (0) to 4.
    DABO_TIMEOUT     # test timeout: <number>[ms], e.g. 4s, 1m, .. 
    DABO_RESULTS_DIR # where to copy results

Option switches (overriding the environment variables):

    -e $DABO_EMAIL
    -s $DABO_SUBJPFX
    -v $DABO_VERBOSITY
    -t $DABO_TIMEOUT
    -d $DABO_RESULTS_DIR  # -o too
    -r $DABO_RESULTS_OPTS # any from "hnrt.", default "nrt"
    DABO_RESULTS_OPTS / -r takes a combination of:
     h : internally uses nohup
     n : run test under "nice -n 10"
     r : script returns false on any failure
     t : timestamp in filenames
     . : ignored (but allows to override defaults)

Option switches meant for interactive use:

    -h :            print help message and exit
    -L :            view test log with less immediately
    -P : if passed, view test log with less immediately
    -F : if failed, view test log with less immediately
    -D : dry run: checks arguments and exit
' # meant for copy paste in the README
DN=/dev/null
VIEW_LOG=''
DRY_RUN=''
set -e
test "`uname`" = Linux # not tested elsewhere
function on_help() { echo "${DABO_HELP}";exit; }
function echo_V1() { if test "${VL}" -ge 1 ; then echo "${@}"; fi; }
OPTSTRING="e:s:v:t:d:o:r:DFLPh"
while getopts $OPTSTRING NAME; do
	case $NAME in
		e) DABO_EMAIL=$OPTARG;;
		s) DABO_SUBJPFX=$OPTARG;;
		v) DABO_VERBOSITY=$OPTARG;;
		t) DABO_TIMEOUT=$OPTARG;;
		r) DABO_RESULTS_OPTS=$OPTARG;;
		o|d) DABO_RESULTS_DIR=$OPTARG;;
		F) VIEW_LOG+='F';;
		P) VIEW_LOG+='P';;
		L) VIEW_LOG+='FP';;
		D) DRY_RUN=yes;;
		h) on_help;;
		*) false
	esac
done
shift $((OPTIND-1))
test $# = 0 && on_help
test -z "$DABO_VERBOSITY" && echo "INFO: DABO_VERBOSITY [-v] unset -- will operate quietly (as with 0)."
VL=${DABO_VERBOSITY:="0"}
[[ "$VL" =~ ^[01234]$ ]] || { echo "ERROR: DABO_VERBOSITY=$DABO_VERBOSITY : 0 to 4!"; false; }
unset TSTS
declare -a TSTS
TSTS=($@)
echo_V1 "INFO: Will go through tests directories: ${TSTS[*]}"; 
for ((TSTI=0;TSTI<${#TSTS[@]};++TSTI)) ; do
	TST=${TSTS[$TSTI]}
	if TBN=`basename $TST` TDN=`dirname  $TST` && test -f "$TST" -a "$TBN" = test.sh -a -n "$TDN" -a -d "$TDN" -a -n "${TDN//./}" ; then
		#echo_V1 "INFO: $TDN/$TBN invocation form not supported -- you should specify $TDN instead."; TDN=$TST TBN=test.sh
		TSTS[$TSTI]=$TDN # tolerate this form as well test.sh
	else
		TDN=$TST TBN=test.sh
	fi
	if test ! -f "$TDN/test.sh" ; then echo_V1 "INFO: $TST is not a valid test directory -- (will be skipped)."; continue; fi
done
EMAIL=${DABO_EMAIL:=""}
test -z "$EMAIL" && echo_V1 "INFO: DABO_EMAIL [-e] unset -- no report email will be sent."
test "$EMAIL" = "${EMAIL/%@*/@}${EMAIL/#*@/}" || { echo "ERROR: DABO_EMAIL=$DABO_EMAIL : invalid email address!"; false; }
test -n "$EMAIL" && echo_V1 "INFO: DABO_EMAIL=$DABO_EMAIL : will send a report email."
TO=4s;
test -z "$DABO_TIMEOUT" && echo_V1 "INFO: DABO_TIMEOUT [-t] unset -- will use default test timeout of $TO."
test -n "$DABO_TIMEOUT" && echo_V1 "INFO: DABO_TIMEOUT=${DABO_TIMEOUT}: each test will be run with this timeout."
TO=${DABO_TIMEOUT:="$TO"}
[[ "$TO" =~ ^[0-9]+[ms]$ ]] || { echo "ERROR: DABO_TIMEOUT=$DABO_TIMEOUT: <number>[ms], e.g. $TO, 1m, ..!"; false; }
DSP="TEST: "
test -z "$DABO_SUBJPFX" && echo_V1 "INFO: DABO_SUBJPFX [-s] unset -- will use default email subject prefix \"$DSP\"."
test -n "$DABO_SUBJPFX" && echo_V1 "INFO: DABO_SUBJPFX=${DABO_SUBJPFX}: user-set email subject prefix."
DSP=${DABO_SUBJPFX:="$DSP"} # default subject prefix
if test "$VL" -ge 2 ; then VMD=-v; VS=''; VCP=-v; VTAR=v; else VMD=''; VS=-q; VCP=''; VTAR=''; fi
if declare -f module 2>&1 > $DN ; then
	ML="`module list -t`"
	for MN in ${ML} ; do 
		if [[ "$MN" =~ $USER ]] ; then 
			echo_V1 "INFO: unload module $MN" ;
			module unload $MN;
		fi
	done
	for MP in ${MODULEPATH//:/ } ; do 
		if [[ "$MP" =~ $USER ]] ; then 
			echo_V1 "INFO: unuse path $MP" ;
			module unuse $MP; module unuse $MP; # yes, twice
		fi
	done
fi
test "$VL" -ge 4 && set -x
if echo $MODULEPATH | grep $USER; then echo "ERROR: shall unload personal modules first!"; false; fi
ECT="'mkdir mytest; echo true  > mytest/test.sh; $0 mytest;'"
ECF="'mkdir mytest; echo false > mytest/test.sh; $0 mytest;'"
EI="You can create your own first test case easily, e.g.: $ECT or $ECF."
UI="See $0 -h."
PASS=''
FAIL=''
POFL=''
ATFL=''
FOFL=''
CHEAPTOHTMLRE='s/$/<br>/g'
PDIR=`pwd`/
test -z "$DABO_RESULTS_DIR" && echo_V1 "INFO: DABO_RESULTS_DIR [-d/-o] unset -- will use working directory: $PDIR"
PDIR=${DABO_RESULTS_DIR:="$PDIR"}
[[ "$PDIR" =~ /$ ]] || PDIR+='/'
DROH='hrt.' # all
DRO='nrt' # default
test -z "$DABO_RESULTS_OPTS" && echo_V1 "INFO: DABO_RESULTS_OPTS [-r] unset -- will use: \"$DRO\""
DRO=${DABO_RESULTS_OPTS:="$DRO"}
[[ "$DRO" =~ ^[hnrt.]+$ ]] || { echo "ERROR: DABO_RESULTS_OPTS=$DABO_RESULTS_OPTS: shall contain chars from [$DROH] ..!"; false; }
MPIF='/etc/profile.d/modules.sh' # module path include file
if test -r "$MPIF" && ! declare -f module > /dev/null ; then echo_V1 "INFO: activating module system by including $MPIF"; . $MPIF; fi
if test -z "${TSTS[*]}" ; then echo_V1 "INFO: No test directory specified at the command line -- exiting. $UI $EI"; exit ; fi
if test "$DRY_RUN" = yes ; then echo_V1 "INFO: dry run requested: doing nothing and exiting."; exit; fi
mkdir -p ${VMD} -- "$PDIR"
test -d "$PDIR"
rm -f -- $PDIR/*.shar
export DABO_SCRIPT="`which $0`" 
for TST in ${TSTS[*]}; do
	TST=${TST/%\//} # elicit trailing slash
	if   test -d "$TST" -a "${TST:0:1}" = '/'; then # absolute path
		TS=$TST/test.sh
		PD=$PDIR
		DP=$TST
	elif test -d "$TST" -a "${TST:0:1}" = '.'; then
		TS=`pwd`/$TST/test.sh
		PD=$PDIR
		DP=$TST
#	elif test ! -d "$TST" ; then
#		echo "ERROR: $TST is not a directory! $UI";
#		false
	elif test ! -d "$TST" ; then
		echo_V1 "INFO: $TST is not a test directory -- SKIPPING! $UI";
		continue;
	else
		TS=`pwd`/$TST/test.sh
		PD=$PDIR
		DP=$TST # relative
	fi
	test "$VL" -ge 2 && echo_V1 "INFO: Will write logs to $PD$DP"
	test ! -f $TS && { echo_V1 "INFO: $TS is not present -- SKIPPING test \"$TST\""; continue; }
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
	pushd $TD/.. > $DN
	TTBN=`basename $TD` # test tarball name
	TTB=${DABO_RESULTS_DIR}/${TBN}.tar.gz
	tar c${VTAR}zf ${TTB} --transform s/${TTBN}/${TBN}/g --show-transformed-names ${TTBN}
	pushd $TD > $DN
	mkdir -p ${VMD} -- `dirname $LF`
	( 	if [[ "$DRO" =~ n ]]; then NICEL="10"; else NICEL='0'; fi # 
		nice -n ${NICEL} timeout $TO bash --norc -e $TS 2>&1 ; ) 1> $LF \
		&& {        TR="pass"; echo "PASS TEST: $TST"; PASS+=" $TBN"; } \
		|| { TC=$?; TR="fail"; echo "FAIL TEST: $TST`test $TC == 124 && echo ' [TIMEOUT:'${TO}']'`""`echo ' '[LOG: $LF]`"; FAIL+=" $TBN"; }
	#mailx -s test-batch-${TBN}:${TR} -a ${LF} -S from="${EMAIL}" "${EMAIL}"
	SC=dabo.sh # this script basename
	OFL="`find -maxdepth 1 -name test.sh -o -name '*.c' -o -iname '*.h' -o -iname '*.F90'`"
	test "$VL" -ge 2 && ls -l -- $OFL 
	for TF in $OFL ; do
		HS=${DP}/`basename ${TF}`.html
		mkdir -p ${VMD} -- `dirname $PD$HS`
		if [[ "$DRO" =~ h ]]; then NOHUP=nohup ; else NOHUP=''; fi
		! HOME=. ${NOHUP} vim -E $TF -c 'syntax on' -c 'TOhtml' -c "w! ${PD}$HS" -c 'qall!' 2>&1 > $DN
		test -f ${PD}${HS}
		if cmp $TF ${PD}${HS} > $DN ; then echo "WARNING: $TF -> ${PD}${HS} conversion failed"; sed -i "$CHEAPTOHTMLRE" ${PD}${HS}; true; fi # e.g. nohup vim
		#elinks ${PD}${HS}
		test "$TR" = "pass" && POFL="$POFL ${HS}"
		test "$TR" = "fail" && FOFL="$FOFL ${HS}"
	done
	test -f $LF
	cp $LF $LF.html && sed -i 's/$/<br>/g' $LF.html
	test "$TR" = "fail" && test "$VL" -ge 3 && nl $LF
	test "$TR" = "pass" && ATFL="$ATFL ${TTB}"
	test "$TR" = "pass" && POFL="$POFL ${LP}"
	test "$TR" = "fail" && FOFL="$FOFL ${LP}"
	test "$TR" = "pass" -a -n "${IFL}" && mkdir -p ${VMD} -- $PD$DP && for f in ${IFL}; do if test -f $f; then cp -np ${VCP} -- $f $PD$DP; fi ; done
	test "$TR" = "fail" -a -n "${IFL}" && mkdir -p ${VMD} -- $PD$DP && for f in ${IFL}; do if test -f $f; then cp -np ${VCP} -- $f $PD$DP; fi ; done
	test "$VL" -ge 2 && ls -l
	if ( test "$TR" = "fail" && [[ "$VIEW_LOG" =~ F ]] ) || ( test "$TR" = "pass" && [[ "$VIEW_LOG" =~ P ]] ) ;  then
		less ${LF};
	fi
	rm -fR -- $TD
	{ popd; popd; } > $DN
done
ONLYTEST="${PASS// /}${FAIL// /}"
#FAIL=${FAIL// false/} # ignoring 'false'
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
if test $TC -le 1; then ATS="All tests"; else ATS="All tests"; fi
test -z "$FAIL" && test -n "$PASS" && CMT+="$ATS passed [$PC/$TC]"
test -n "$FAIL" && test -z "$PASS" && CMT+="$ATS failed [$FC/$TC]"
test -n "$FAIL" && test -n "$PASS" && CMT+="Some tests failed [$FC/$TC]"
SL="$CMT"
LOFL=""
LOPL=""
test -n "$FOFL" && for t in $FOFL ; do [[ "$t" =~ \.log ]] && LOFL+=" $t" ; done; 
test -n "$POFL" && for t in $POFL ; do [[ "$t" =~ \.log ]] && LOPL+=" $t" ; done; 
#ls -- *.html *.log | sort | sed 's/\(.*$\)/<a href="\1">\1<\/a>\n<br\/>/g' > index.html
#SL="${FAIL:+FAIL:}${FAIL} ${PASS:+PASS:}${PASS}"
cd $PDIR
FL='' PL=''
if [[ "$DRO" =~ t ]]; then TSL="-`date +%s`"; else TSL=''; fi # time stamp for the logs
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
ATTL="${FL} ${PL} ${FF} ${PF} ${LS} ${ATFL}"
if test -n "${ATTL// /}"; then echo_V1 "INFO: Give a look at: ${ATTL}"; fi
test -z "$FAIL" && FF=''
test -z "$PASS" && PF=''
test -z "$FAIL" && test -z "$PASS" && SL="$SL $ATS test passed"
if test $TC -le 1; then SL+=" [$ONLYTEST]"; fi
if test -n "$EMAIL" ; then test -n "$ONLYTEST" && \
	echo_V1 "INFO: Mailed to \"${AUTHOR} <$EMAIL>\" with subject \"$SL\"" && \
	echo -e "$BODY" | mailx -s "$DSP$SL" -S from="${AUTHOR//@/-at-} <${EMAIL}>" ${FL:+-a }${FL} ${PL:+-a }${PL} ${FF:+-a }${FF} ${PF:+-a }${PF} ${LS:+-a }${LS} ${ATFL:+-a }${ATFL} "${EMAIL}";
fi
if test $TC -eq 0; then echo "WARNING: no test executed. $UI"; fi;
if [[ "$DRO" =~ r ]] && test $FC -gt 0 ; then false; fi
