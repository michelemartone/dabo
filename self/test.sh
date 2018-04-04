#!/bin/bash
set -e
set -x
[[ "$SCAMC_SCRIPT" =~ scamc ]] || false
test -n "$SCAMC_SCRIPT"
test -f "$SCAMC_SCRIPT"
test -x "$SCAMC_SCRIPT"
unset SCAMC_EMAIL
unset SCAMC_VERBOSITY
unset SCAMC_TIMEOUT
unset SCAMC_RESULTS_DIR
#
function build_test()
{
	TD=self_internal
	TS=$TD/test.sh
	rm -fR $TD failed.log passed.log
	mkdir  $TD
	echo "$@" > $TS
	test -f $TS
	$SCAMC_SCRIPT $TD
}
function post_any()
{
	test -n $TD
	test -d $TD
	rm -R $TD
}
function post_pass()
{
	test ! -f failed.log
	test   -f passed.log
	nl passed.log
	rm        passed.log
	post_any
}
function post_fail()
{
	test   -f failed.log
	test ! -f passed.log
	nl failed.log
	rm        failed.log
	post_any
}
export SCAMC_TIMEOUT=1s
export SCAMC_VERBOSITY=3
build_test true
post_pass
build_test fail
post_fail
build_test 'sleep 2'
post_fail
