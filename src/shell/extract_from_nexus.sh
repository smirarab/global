#!/bin/sh
f=$1
n=$2 

tail -n+`grep -m1 -n -o "TREE " $f |sed -e "s/:.*//g"` $f|head -n $n|sed -e "s/^.* //g"
