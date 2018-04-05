SCAMC
=====
# SCAnt Modulefiles Checker

## A minimalistic, non-invasive helper to user-side
 * testing
 * documentation
 * reporting
of short shell scripts as test cases.

## SCAMC is NOT meant
 * for exhaustive testing
 * to test the whole system
 * to document modulefiles
 * to be particularly portable
 * to replace per-software test suites
 * to write e.g. automated benchmarks 

## SCAMC is meant to
 * run on Linux
 * produce logs useful as document snippets
 * spot failing use cases
 * report failure logs via email
 * save results in a custom directory

## Workflow
 * you create a directory, named e.g. `$MYTEST`
 * you write test script `$MYTEST/test.sh`, which:
   - shall succeed (e.g. exit 0) on success
   - shall fail    (e.g. exit 1) on failure
   - shall make no assumptions on the running directory
   - runs behalf of the user (so, caution with your tests)
 * you run it: `./scamc.sh $MYTEST`
   getting PASS / FAIL info for each test
 * path invocation of `$MYTEST` shall be relative
 * you can run many, e.g.: `./scamc.sh $TEST1 $TEST2`
 * such test scripts shall be portable to any other testing facility

## Options
The script works in the current directory.
It reads the following environment variables:

    SCAMC_EMAIL       # if set, send report to this email address.
    SCAMC_VERBOSITY   # print verbosity: (0) to 3.
    SCAMC_TIMEOUT     # test timeout: <number>[ms], e.g. 4s, 1m, .. 
    SCAMC_RESULTS_DIR # where to copy results

## Example executions

    # intro:
    git clone git@github.com:michelemartone/scamc.git && cd scamc # get the code
    ./scamc.sh true         # run trivial passing test, in 'true' directory
    ./scamc.sh false        # run trivial failing test
    ./scamc.sh self         # run self test -- shall pass
    ./scamc.sh              # run all tests -- some will fail
    ./scamc.sh example_pass # run user example test
    nl example_pass/test.sh # give a look -- eventually edit
    git clone git@github.com:tests/examples.git scamc_examples && ./scamc.sh scamc_examples/* # examples
    git clone git@github.com:tests/mm.git scamc_mm && ./scamc.sh scamc_mm/demos/*
    #
    # write your own tests:
    mkdir -p unfinished_test ; echo 'echo my test' > unfinished_test/test.sh 
    SCAMC_VERBOSITY=2 ./scamc.sh unfinished_test  # inspect your running tests
    mv unfinished_test my_test
    SCAMC_EMAIL=my@email ./scamc.sh my_test
    # 
    # use different collections of tests:
    SCAMC_TIMEOUT=9s SCAMC_RESULTS_DIR=$PWD/../demos_results ./scamc.sh small_demos/*
    SCAMC_TIMEOUT=1s SCAMC_RESULTS_DIR=$PWD/../scamc_results ./scamc.sh env_quick_tests/*
    SCAMC_TIMEOUT=1m SCAMC_RESULTS_DIR=$PWD/../scamc_results ./scamc.sh path-to-slow_test
    #
    # nightly runs:
    # crontab -e # 00 23 * * * SCAMC_EMAIL=me@there ~/src/scamc/scamc.sh ~/testsdir

