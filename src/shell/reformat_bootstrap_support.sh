#!/bin/bash

test  $# == 1 || { echo USAGE: $0 inputfile; exit 1; }

number="[0-9]*\.\?[0-9]\+\([eE][-+]\?[0-9]\+\)\?";

sed -e "s/:\($number\)\[\([^=]\+=\)\?\([0-9.]\+\)\]/\4:\1/g" $1
