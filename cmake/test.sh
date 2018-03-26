#!/bin/bash
set -e
set -x
#export LC_ALL="en_US.UTF-8"
#export LC_ALL=""
#export LANG="de"
rm -fR Example
#shar -s user@example -m  Example | grep -v $USER > Example.shar && vim Example.shar
which make
which cmake
test -f ./Example.shar
./Example.shar
cd Example # originally from the cmake distribution. see https://cmake.org/examples/
cmake .
make
find -name helloDemo
test -f Demo/helloDemo
test -x Demo/helloDemo
Demo/helloDemo | grep World
cd -
rm -fR Example
