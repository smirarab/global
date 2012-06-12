#!/bin/sh
#sed -e "s/[^[]*\[\([^]]*\)]/\1\n/g" -e "s/,.*//g" $*|head -n-1| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count, max, min}'
if [ ! $# == 2 ]; then  
  echo USAGE: $0 tree threshold
  exit 1;
fi

S=$2
if [ $S -gt 100 ] || [ $S -lt 0 ]; then
	S=75
fi
cat $1| sed -e "s/[^)]*[);]\([0-9]*\)/\1 /g"|tr " " "\n"|awk '
BEGIN {sum=0;num=0;min=100;max=0;high=0;}
{if ($1 >=0 && $1 <=100) {
	sum+=$1;num++; 
	if ($1>max) {max=$1}; 
	if($1<min) {min=$1};
	if($1>= '$S') {high++};
	}
}
END {print sum/num " " max " " min " " num " " high}'
