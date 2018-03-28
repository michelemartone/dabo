## SCAMC
# SCAnt Modulefiles Checker

A minimalistic, non-invasive approach to user-side:
 * testing
 * documentation
 * reporting
of short shell scripts.

This is not meant for exhaustive testing.
Neither to test the whole system.
Neither to document modulefiles.
Neither to work on any computer.
Just to give a glimpse into use and minimal correctness,
and if run from, e.g. cron job, report issues to tester..

Workflow: a user writes a set of tests, and runs them.
Each test is a directory containing 'test.sh' and if
needed, a bunch of extra files. See the attached
example files.
 
TODO list:

Make script stand-alone and independent from srcs dir.
Use a read only tests script dir, and a results dir:
 SCAMC_TESTS_DIR # into PKGS
 SCAMC_FAILED_DIR
 SCAMC_PASSED_DIR
 SCAMC_EMAIL
 SCAMC_VERBOSITY
 SCAMC_TIMEOUT

Test for the test itself.

Modules shall be checked for e.g.:
 *_LDFLAGS # only paths
 *_CPPFLAGS # only flags
 *_CXXFLAGS # only flags
 *_CFLAGS # only flags
 *_FCFLAGS # only flags
 *_LIBS # complete library
 LD_LIBRARY_PATH # only paths
 *_CC #
 *_CXX #
 *_FC #
 *_USER_TEST # 
 *_DEV_TEST # 
 ...

And:
 * adherence to having e.g.
   .mantainer # with *_DEV_TEST stuff and maintainer
 * might integrate old but working
   https://svn.lrz.de/repos/hlr/trunk/testsuite/
 
 * production of directories:
  - results -- for internal usage, with logs
  - postprocessed files -- for publishing
  
Test of simple examples like:
 * gfortran -fexternal-blas .. 
 * new specific interesting compiler features 
 
