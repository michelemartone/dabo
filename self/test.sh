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
function tests()
{
	TD=self_internal
	rm -fR $TD failed.log passed.log
	mkdir  $TD
	TS=$TD/test.sh
cat >> $TS << EOF
#!/bin/bash
echo Successful test: $TS
true
EOF
	test -f $TS
echo mango
	$SCAMC_SCRIPT $TD
echo papaya
	pwd
	test   -f passed.log
	test ! -f failed.log
	nl passed.log
	rm -R $TD
	rm passed.log
	#
	mkdir  $TD
	TS=$TD/test.sh
cat >> $TS << EOF
#!/bin/bash
echo Failing test: $TS
false
EOF
echo banana
	test -f $TS
	"$SCAMC_SCRIPT" $TD
	pwd
	test   -f failed.log
	test ! -f passed.log
	nl failed.log
	rm -fR $TD
}
#
#
export SCAMC_TIMEOUT=1s
export SCAMC_VERBOSITY=3
tests
#
