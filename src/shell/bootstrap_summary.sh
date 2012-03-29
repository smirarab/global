#!/bin/sh
#sed -e "s/[^[]*\[\([^]]*\)]/\1\n/g" -e "s/,.*//g" $*|head -n-1| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count, max, min}'
cat $1| sed -e "s/[^)]*[);]\([0-9]*\)/\1 /g"|tr " " "\n"|awk 'BEGIN {sum=0;num=0;min=100;max=0;}{if ($1 >=0 && $1 <=100) {sum+=$1;num++; if ($1>max) {max=$1}; if($1<min) {min=$1};}} END {print sum/num " " max " " min}'
