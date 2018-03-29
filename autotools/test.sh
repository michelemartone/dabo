#!/bin/bash
# this test might take ~10s or so..
#module switch gcc
#module switch autotools
set -e
#module help autotools
#module show autotools
#module load autotools
set -x

rm -fR autom4te.cache/ .deps/
rm -f \
 aclocal.m4 AUTHORS ChangeLog config.log config.status* configure* \
 configure.ac COPYING depcomp* hello* hello.c hello.o INSTALL \
 install-sh* Makefile Makefile.am Makefile.in missing* \
 NEWS README test.sh.html test.sh.log
ls
#read
rm -f hello.c
cat > hello.c << EOF
int main()
{
	return 0;
}
EOF
test -f hello.c

rm -f Makefile.am
cat > Makefile.am << EOF
bin_PROGRAMS=hello
hello_c_SOURCES=hello.c
tests: hello
	./\$<
e:
	\$(EDITOR) hello.c
t x: tests
EOF
test -f Makefile.am

rm -f configure.ac
cat > configure.ac << EOF
dnl Example: C project, with Automake Makefile.
AC_PREREQ([2.54])
AC_INIT([cpp_example],[0.0],[noreply@organization.tld])
AC_COPYRIGHT([Copyright (c) 2018-2018, Copyright holder])
AM_INIT_AUTOMAKE
AC_PROG_CC
AC_MSG_NOTICE([Created a Makefile.])
AC_OUTPUT([Makefile])
EOF
test -f configure.ac

touch './INSTALL' './NEWS' './README' './AUTHORS' './ChangeLog'

rm -f configure
rm -f Makefile
rm -f Makefile.in
autoreconf -i -v
test -f configure
test -f Makefile.in
./configure
test -f Makefile
make
test -x hello
true
