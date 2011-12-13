#!/bin/sh
sed -e "s/[^[]*\[\([^]]*\)]/\1\n/g" -e "s/,.*//g" $*|head -n-1| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count, max, min}'
