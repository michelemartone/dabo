#!/bin/bash
set -e
set -x
which vim
which nohup
which sed
which grep
which echo
which basename
which true
which false
which shar
which mail
which nice
# false # uncomment to make test fail
[[ "$DABO_SCRIPT" =~ dabo ]] || false
test -n "$DABO_SCRIPT"
test -f "$DABO_SCRIPT"
test -x "$DABO_SCRIPT"
#
function build_test()
{
	TD=self_internal
	TS=$TD/test.sh
	rm -fR $TD ${DABO_RESULTS_DIR}failed.log ${DABO_RESULTS_DIR}passed.log
	mkdir  $TD
	echo "$@" > $TS
	test -f $TS
	$DABO_SCRIPT $TD
}
function build_failing_test()
{
	if build_test $@ ; then false; else true; fi
}
function post_any()
{
	test -n $TD
	test -d $TD
	rm -R $TD
}
function post_pass()
{
	test ! -f ${DABO_RESULTS_DIR}failed.log
	test   -f ${DABO_RESULTS_DIR}passed.log
	nl ${DABO_RESULTS_DIR}passed.log
	rm        ${DABO_RESULTS_DIR}passed.log
	post_any
}
function post_fail()
{
	test   -f ${DABO_RESULTS_DIR}failed.log
	test ! -f ${DABO_RESULTS_DIR}passed.log
	nl ${DABO_RESULTS_DIR}failed.log
	rm        ${DABO_RESULTS_DIR}failed.log
	post_any
}
function basic_tests()
{
	build_test true
	post_pass
	build_test false
	post_fail
}
unset DABO_EMAIL
unset DABO_VERBOSITY
unset DABO_TIMEOUT
export DABO_RESULTS_DIR=`pwd`/
export DABO_RESULTS_OPTS=h.
#
WC=`$DABO_SCRIPT -h | wc -c`
test $WC -ge 1589
#
VL='1 2 3 4'
for DABO_VERBOSITY in 0 $VL; do
	export DABO_VERBOSITY
	#false
	eval WC_$DABO_VERBOSITY=`basic_tests 2>&1 | wc -c`
done
#
for DABO_VERBOSITY in   $VL; do # test for non-decreasing verbosity
	eval test    $DABO_VERBOSITY -gt $((DABO_VERBOSITY-1))
	eval test \$WC_$DABO_VERBOSITY -ge \$WC_$((DABO_VERBOSITY-1))
done
#
export DABO_TIMEOUT=1s
export DABO_VERBOSITY=3
build_test 'sleep 2'
post_fail
basic_tests
#
export DABO_RESULTS_DIR=`pwd`/custom_results_dir/
test -n $DABO_RESULTS_DIR
rm -fR  "$DABO_RESULTS_DIR"
mkdir -p "$DABO_RESULTS_DIR"
test -d "$DABO_RESULTS_DIR"
build_test true
post_pass
build_test false
post_fail
#
export DABO_EMAIL=wrong_address
build_failing_test true
#
