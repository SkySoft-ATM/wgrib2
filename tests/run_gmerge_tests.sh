#!/bin/sh
# This script runs a series of tests using the RPN calculator
#
# Alyson Stahl 5/7/2024

set -e
echo ""
echo "*** Running gmerge tests"

file=data/gdas.t12z.pgrb2.1p00.anl.75r.grib2

arg=''
i=0
while [ $i -lt 201 ]
do
  arg="$arg $file"
  i=`expr $i + 1`
done

../aux_progs/gmerge tmp.gmerge.grb $arg
echo "*** SUCCESS!"
exit 0
