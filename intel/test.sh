#!/bin/bash
#test "`basename $0`" = "$0"
set -e
module load intel
set -x
module list
cat > matmul.F90 << EOF
! Based on
! http://www.lahey.com/docs/lfenthelp/F95ARMATMULFn.htm
PROGRAM MMT
  INTEGER :: a1(2,3),a5(5,2),b3(3),b2(2)
  COMPLEX :: c2(2)
  a1=RESHAPE((/1,2,3,4,5,6/),SHAPE(a1))
  a5=RESHAPE((/0,1,2,3,4,5,6,7,8,9/),SHAPE(a5))
  b2=(/1,2/)
  b3=(/1,2,3/)
  WRITE(*,"(2i3)") a1 ! WRITES  1  2
                      !         3  4
                      !         5  6
  WRITE(*,*) MATMUL(a1,b3) ! WRITES 22 28
  WRITE(*,*) MATMUL(b2,a1) ! WRITES 5 11 17
  WRITE(*,"(5i3)") a5 ! writes  0  1  2  3  4
                      !         5  6  7  8  9
  WRITE(*,"(5i3)") MATMUL(a5,a1) ! WRITES 10 13 16 19 22
                                  !        20 27 34 41 48
                                  !        30 41 52 63 74
  c2=(/(-1.,1.),(1.,-1.)/)
  WRITE(*,*) MATMUL(a5,c2) ! WRITES (5.,-5.) five times 
END PROGRAM MMT
EOF
ifort matmul.F90 -o matmul -qopt-matmul      # no MKL
ldd ./matmul  | grep -v mkl
ifort matmul.F90 -o matmul -qopt-matmul -mkl #    MKL
ldd ./matmul  | grep    mkl
