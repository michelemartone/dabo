#!/bin/bash
set -e
module help subversion
module show subversion
module load subversion
set -x
which svn
svn help ls
svn --version
