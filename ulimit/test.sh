#!/bin/bash
set -e
set -x
echo before timeout
timeout 2s sleep 1 && true
timeout 1s sleep 2 || test $? == 124
echo after timeout
