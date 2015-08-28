#!/bin/bash

awk 'NR==1 {n=$1;k=$2;i=k;} NR > 1 { if (i==k) {printf "\n";print ">"$1;i=0;} else {i=i+length($0);printf $0}}' $1 |tail -n+2 >$2
