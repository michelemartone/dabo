## SCAMC
# SCAnt Modulefiles Checker

An approach to:
 * systematize tests of modules
 * test installed software modules base
 * document minimal use cases
 * reporting (e.g. a bunch of scripts and HTML files)

This effort does not aim to be exhaustive by any means.

But aims to be:
 * gradual
 * minimal
 * non invasive

TODO list:

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
 
