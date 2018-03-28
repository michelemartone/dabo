## SCAMC
# SCAnt Modulefiles Checker

A minimalistic, non-invasive approach to user-side:
 * testing
 * documentation
 * reporting
of short shell scripts.

SCAMC is not meant for exhaustive testing.
Neither to test the whole system.
Neither to document modulefiles.
Neither to work on any computer.
Just to give a glimpse into use and minimal correctness,
and if running from, e.g. cron job, reporting issues to tester..

Workflow: you write a set of tests, and run them.
Each test is a directory containing 'test.sh' and if
needed, a bunch of extra files.
See the example directories.
 
The script reacts to the following environment variables:

 SCAMC_EMAIL      : if set, send report to this email address.
 SCAMC_VERBOSITY  : print verbosity: (0) to 3.
 SCAMC_TIMEOUT    : test timeout: <number>[ms], e.g. 4s, 1m, .. 
 SCAMC_RESULTS_DIR: where to copy results; if unset, here.

Example executions:

 ./test.sh
 ./test.sh true
 bash ./test.sh true
 SCAMC_EMAIL=nobody@tld ./test.sh
 SCAMC_VERBOSITY=1 SCAMC_TIMEOUT=5s SCAMC_RESULTS_DIR=`pwd`/../scamc_results ./test.sh
