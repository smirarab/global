#!/bin/sh

if [ $# -lt 1 ]; then
 echo USAGE: $0 inputfile
 exit 1
fi

number="[0-9]*\.\?[0-9]\+\([eE][-+]\?[0-9]\+\)\?";

sed -e "s/:\($number\)\[\([^=]\+=\)\?\([0-9.]\+\)\]/\4:\1/g" $1
