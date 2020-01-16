DABO
====
# Did Anything Break Overnight ?

Maintaining good user experience on a system with multiple users
and administrators requires reproducible procedures, e.g. to:
 - ensure the shell environment is consistent
 - spot erroneous behaviours early on
 - manage user side tickets / incidents

DABO is a humble script to address this.

## A minimalistic, non-invasive helper to user-side
 * testing
 * documentation
 * reporting
of short shell scripts as test cases.

## DABO fits in
 * automated test runs
 * test-driven development

## DABO is NOT meant to
 * replace per-software test suites or documentation
 * test exhaustively the whole system
 * replace e.g. modulefiles documentation (`module help`)
 * implement heavy automated benchmarks 
 * be particularly portable apart from Linux
 * compete with a complete unit testing framework

## DABO can
 * help spoting failing use cases
 * report via email
 * save results in a custom directory
 * produce logs useful as document snippets

## DABO workflow
 * create a directory e.g. `$MYTEST`
 * write test script `$MYTEST/test.sh`, which:
   - shall succeed (e.g. `exit 0`) on success
   - shall fail    (e.g. `exit 1`) on failure
   - shall make NO assumptions on the running directory
   - runs behalf of the user (so: write safe code)
 * run it dry:    `./dabo.sh -D $MYTEST` # does nothing
 * run it really: `./dabo.sh    $MYTEST`
   getting PASS / FAIL info for each test
 * run with options, e.g.: `./dabo.sh $OPTS $TEST1 $TEST2 ...`
 * write only small short and stand-alone test scripts

## DABO caution notes
 * DABO performs no chroot or permissions downgrade
 * DABO uses a timeout: if too short, might leave test files around
 * DABO runs under `nice` so not to overload machine
 * DABO copies test each supplied directory, script, and input
   to a temporary directory under /dev/shm, then destroys it
 * run test scripts of other people under a shared restricted account !!!

## DABO documentation: (from `dabo -h`)
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
    DABO_EMAIL_FROM  # if set, send report from this email address.
    DABO_EMAIL_BCC   # if set, send in Bcc: to this email address.
    DABO_EMAIL_CC    # if set, send in Cc: to this email address.
    DABO_SUBJPFX     # if set, email subject prefix
    DABO_VERBOSITY   # print verbosity: (0) to 4.
    DABO_TIMEOUT     # test timeout: <number>[ms], e.g. 5s, 1m, .. 
    DABO_RESULTS_DIR # where to copy results

Option switches (overriding the environment variables):

    -b $DABO_EMAIL_BCC
    -c $DABO_EMAIL_CC
    -e $DABO_EMAIL
    -f $DABO_EMAIL_FROM
    -s $DABO_SUBJPFX
    -v $DABO_VERBOSITY
    -t $DABO_TIMEOUT
    -d $DABO_RESULTS_DIR  # -o too
    -r $DABO_RESULTS_OPTS # any from "ahnrst.", default "nrt"
    DABO_RESULTS_OPTS / -r takes a combination of:
     a : attach tar archives of test cases
     h : internally uses nohup
     n : run test under "nice -n 10"
     r : script returns false on any failure
     s : archive results in shar format
     t : timestamp in filenames
     . : ignored (but allows to override defaults)

Option switches meant for interactive use:

    -h :            print help message and exit
    -L :            view test log with less immediately
    -P : if passed, view test log with less immediately
    -F : if failed, view test log with less immediately
    -D : dry run: checks arguments and exit

## DABO examples

    # intro:
    git clone git@github.com:michelemartone/dabo.git && cd dabo # get the code
    ./dabo.sh -D true      # dry run: what would be executed ?
    ./dabo.sh    true      # run trivial passing test, in "true" directory
    ./dabo.sh    false     # run trivial failing test
    ./dabo.sh    self      # run self test -- shall pass
    ./dabo.sh              # run all tests -- some will fail
    ./dabo.sh example_pass # run user example test
    nl example_pass/test.sh # give a look -- eventually edit
    git clone git@github.com:tests/examples.git dabo_examples && ./dabo.sh dabo_examples/* # examples
    git clone git@github.com:tests/mm.git dabo_mm && ./dabo.sh dabo_mm/demos/*
    #
    # write your own tests:
    mkdir -p unfinished_test ; echo "echo my test" > unfinished_test/test.sh 
    DABO_VERBOSITY=3 ./dabo.sh unfinished_test  # inspect your running tests
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
    #
    ## in your ~/.bashrc:
    # $ alias dabo="dabo.sh -e `pinky -l $USER | grep ^Login |sed 's/^Login.*: *//g;s/ /./g;s/$/\@lrz.de/'`"

