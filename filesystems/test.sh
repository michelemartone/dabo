#!/bin/bash
set -e
set -x
if test "$LRZ_SYSTEM" = "Cluster" ; then
	test -n "$WORK"
	test -d "$WORK"
	test -n "$SCRATCH"
	test -d "$SCRATCH"
	test -n "$HOME"
	test -d "$HOME"
	test -n "$PROJECT"
	test -d "$PROJECT"
	test -z "$REALLY_WEIRD_DIR_NAME"
	#test -n "$REALLY_WEIRD_DIR_NAME" # uncomment to break
else
	# will break elsewhere
	false
fi
