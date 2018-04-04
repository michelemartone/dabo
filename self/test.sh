#!/bin/bash
set -e
set -x
[[ "$SCAMC_SCRIPT" =~ scamc ]] || false
test -n "$SCAMC_SCRIPT"
test -f "$SCAMC_SCRIPT"
test -x "$SCAMC_SCRIPT"
#
function build_test()
{
	TD=self_internal
	TS=$TD/test.sh
	rm -fR $TD ${SCAMC_RESULTS_DIR}failed.log ${SCAMC_RESULTS_DIR}passed.log
	mkdir  $TD
	echo "$@" > $TS
	test -f $TS
	$SCAMC_SCRIPT $TD
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
	test ! -f ${SCAMC_RESULTS_DIR}failed.log
	test   -f ${SCAMC_RESULTS_DIR}passed.log
	nl ${SCAMC_RESULTS_DIR}passed.log
	rm        ${SCAMC_RESULTS_DIR}passed.log
	post_any
}
function post_fail()
{
	test   -f ${SCAMC_RESULTS_DIR}failed.log
	test ! -f ${SCAMC_RESULTS_DIR}passed.log
	nl ${SCAMC_RESULTS_DIR}failed.log
	rm        ${SCAMC_RESULTS_DIR}failed.log
	post_any
}
function basic_tests()
{
	build_test true
	post_pass
	build_test false
	post_fail
}
unset SCAMC_EMAIL
unset SCAMC_VERBOSITY
unset SCAMC_TIMEOUT
unset SCAMC_RESULTS_DIR
#
VL='1 2 3'
for SCAMC_VERBOSITY in 0 $VL; do
	export SCAMC_VERBOSITY
	#false
	eval WC_$SCAMC_VERBOSITY=`basic_tests 2>&1 | wc -c`
done
#
for SCAMC_VERBOSITY in   $VL; do # test for non-decreasing verbosity
	eval test    $SCAMC_VERBOSITY -gt $((SCAMC_VERBOSITY-1))
	eval test \$WC_$SCAMC_VERBOSITY -ge \$WC_$((SCAMC_VERBOSITY-1))
done
#
export SCAMC_TIMEOUT=1s
export SCAMC_VERBOSITY=3
build_test 'sleep 2'
post_fail
basic_tests
#
export SCAMC_RESULTS_DIR=`pwd`/custom_results_dir/
test -n $SCAMC_RESULTS_DIR
rm -fR  "$SCAMC_RESULTS_DIR"
mkdir -p "$SCAMC_RESULTS_DIR"
test -d "$SCAMC_RESULTS_DIR"
build_test true
post_pass
build_test false
post_fail
#
export SCAMC_EMAIL=wrong_address
build_failing_test true
#
