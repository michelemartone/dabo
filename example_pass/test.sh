#!/bin/bash
# This is an example test script file.
# 
# It is a BASH script file.
# The return code of this script will determine success or failure of the test. 
# The script shall be executed from a temporary directory.
#
# It is the test author responsibility to write a safe test, that is a script
# not having undesired side effects --- like deleting files by mistake.

#false  # if false were the last line of the test, the test would have failed
#test $? = 1 # failure

true   # if this were the last line of the test, the test would have passed
test $? = 0 # success

set -e # now on, any command failing (unless already so, if running bash -e)
true
test $? = 0 # success
echo "The next test line shall not fail --- uncomment it to make fail"
# false  # the whole test fails here
echo "And this line shall be printed."
