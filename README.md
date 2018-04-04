SCAMC
=====
# SCAnt Modulefiles Checker

## A minimalistic, non-invasive approach to user-side:
 * testing
 * documentation
 * reporting
of short shell scripts as test cases.


## SCAMC is not meant...
 * for exhaustive testing
 * to test the whole system
 * to document modulefiles
 * to be particularly portable
 * to replace per-software test suites
 * to write e.g. automated benchmarks 


## SCAMC can:
 * produce logs and script renderings useful as document snippets
 * spot failing use cases
 * report failure logs via email
 * save results in a custom directory


## Workflow:
 * you create a directory, named e.g. `$MYTEST`
 * you write test script `$MYTEST/test.sh`, which:
   - shall succeed (e.g. exit 0) on success
   - shall fail    (e.g. exit 1) on failure
   - shall make no assumptions on the running directory
   - runs behalf of the user (so, caution with your tests)
 * you run it: `./scamc.sh $MYTEST`
 * path invocation of `$MYTEST` shall be relative
 * you can run many, e.g.: `./scamc.sh $TEST1 $TEST2`

The script reacts to the following environment variables:

    SCAMC_EMAIL       # if set, send report to this email address.
    SCAMC_VERBOSITY   # print verbosity: (0) to 3.
    SCAMC_TIMEOUT     # test timeout: <number>[ms], e.g. 4s, 1m, .. 
    SCAMC_RESULTS_DIR # where to copy results; if unset, here.

## Example executions:

    ./scamc.sh
    ./scamc.sh true
    bash ./scamc.sh true
    SCAMC_VERBOSITY=2 ./scamc.sh unfinished_test
    SCAMC_EMAIL=nobody@tld ./scamc.sh
    SCAMC_TIMEOUT=9s SCAMC_RESULTS_DIR=$PWD/../demos_results ./scamc.sh small_demos/*
    SCAMC_TIMEOUT=1s SCAMC_RESULTS_DIR=$PWD/../scamc_results ./scamc.sh env_quick_tests/*
    SCAMC_TIMEOUT=1m SCAMC_RESULTS_DIR=$PWD/../scamc_results ./scamc.sh slow_test
    # crontab -e # 00 23 * * * SCAMC_EMAIL=me@there ~/src/scamc/scamc.sh ~/testsdir
