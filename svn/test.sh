#!/bin/bash
set -e
module help svn
module show svn
module load svn
set -x
which svn
svn help ls
svn --version
