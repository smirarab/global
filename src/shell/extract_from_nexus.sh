#!/bin/sh

## This does not translate taxon names :(

test $# == 2 || { echo USAGE: input_nexus line_count; exit 1; }

f=$1
n=$2 

tail -n+`grep -m1 -n -o "TREE " $f |sed -e "s/:.*//g"` $f|head -n $n|sed -e "s/^.* //g"
