DABO
====
# Did Anything Break Overnight ?

## A minimalistic, non-invasive helper to user-side
 * testing
 * documentation
 * reporting
of short shell scripts as test cases.

## DABO supports
 * automated test run
 * test driven development

## DABO is NOT meant
 * to replace per-software test suites
 * for exhaustive or whole system testing
 * to replace modulefiles documentation
 * to implement heavy automated benchmarks 
 * to be particularly portable

## DABO is meant to
 * run on Linux
 * produce logs useful as document snippets
 * spot failing use cases
 * report via email
 * save results in a custom directory

## DABO workflow
 * you create a directory, named e.g. `$MYTEST`
 * you write test script `$MYTEST/test.sh`, which:
   - shall succeed (e.g. exit 0) on success
   - shall fail    (e.g. exit 1) on failure
   - shall make no assumptions on the running directory
   - runs behalf of the user (so, caution with your tests)
 * you run it: `./dabo.sh $MYTEST`
   getting PASS / FAIL info for each test
 * path invocation of `$MYTEST` shall be relative
 * you can run many, e.g.: `./dabo.sh $TEST1 $TEST2`
 * such test scripts shall be portable to any other testing facility

## DABO caution note
 * DABO performs no chroot or permissions downgrade
 * run tests of other people using a shared restricted account !!!

## DABO options
The script works in the current directory.
It reads the following environment variables:

    DABO_EMAIL       # if set, send report to this email address.
    DABO_SUBJPFX     # if set, email subject prefix
    DABO_VERBOSITY   # print verbosity: (0) to 3.
    DABO_TIMEOUT     # test timeout: <number>[ms], e.g. 4s, 1m, .. 
    DABO_RESULTS_DIR # where to copy results

## DABO examples

    # intro:
    git clone git@github.com:michelemartone/dabo.git && cd dabo # get the code
    ./dabo.sh true         # run trivial passing test, in 'true' directory
    ./dabo.sh false        # run trivial failing test
    ./dabo.sh self         # run self test -- shall pass
    ./dabo.sh              # run all tests -- some will fail
    ./dabo.sh example_pass # run user example test
    nl example_pass/test.sh # give a look -- eventually edit
    git clone git@github.com:tests/examples.git dabo_examples && ./dabo.sh dabo_examples/* # examples
    git clone git@github.com:tests/mm.git dabo_mm && ./dabo.sh dabo_mm/demos/*
    #
    # write your own tests:
    mkdir -p unfinished_test ; echo 'echo my test' > unfinished_test/test.sh 
    DABO_VERBOSITY=2 ./dabo.sh unfinished_test  # inspect your running tests
    mv unfinished_test my_test
    DABO_EMAIL=my@email ./dabo.sh my_test
    # 
    # use different collections of tests:
    DABO_TIMEOUT=9s DABO_RESULTS_DIR=$PWD/../demos_results ./dabo.sh demos/*
    DABO_TIMEOUT=1s DABO_RESULTS_DIR=$PWD/../dabo_results ./dabo.sh envtests/*
    DABO_TIMEOUT=1m DABO_RESULTS_DIR=$PWD/../dabo_results ./dabo.sh thorough/*
    #
    ## crontab -e:
    # DABO=~/src/dabo/dabo.sh
    # EMAIL=me@somewhere
    ## nightly runs (e.g. environment sanity checks):
    # 00 01 * * *   cd ~/mytests; DABO_EMAIL=$EMAIL                  $DABO demos/*
    ## weekly runs (e.g. longer ones):
    # 00 02 * * Sun cd ~/mytests; DABO_EMAIL=$EMAIL DABO_TIMEOUT=5m $DABO thorough/*
