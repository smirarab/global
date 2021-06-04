#!/bin/bash

if [ $# -lt 1 ]; then  
  echo "USAGE: $0 [newick_tree_file] [bootstrap_threshold (optional; defaults to 75)]
        OUTPUT (to stdout): Average_support Maximum_Support Minimum_support Number_of_Internal_Edges Number_of_High_Support_Edges
        OUTPUT (to stderr): support of each branch individually"
  exit 1
fi

S=$2
test -z $S && S=75
#if [ $S -gt 1000 ] || [ $S -lt 0 ]; then
#	echo Threshold $S not recongnized. Give a number between 0 and 1000
#        exit 1
#fi

for x in `cat $1`; do 
  echo $x| sed -e "s/[^)]*[);]\([0-9.]*\)/\1 /g"|tr " " "\n"|awk '/^[0-9]/ {print "'$1'",$1;}' >&2
  echo -n $1" "
  echo $x| sed -e "s/[^)]*[);]\([0-9.]*\)/\1 /g"|tr " " "\n"|awk '
    BEGIN {sum=0;num=0;min=1000;max=0;high=0;}
          {if ($1 >=0 && $1 <=1000) {
	      sum+=$1;num++; 
	      if ($1>max) {max=$1}; 
	      if($1<min) {min=$1};
	      if($1>= '$S') {high++};
	    }
          }
   END    {print sum/num " " max " " min " " num " " high}' 2>/dev/null
done
