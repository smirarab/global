#!/bin/sh
if [ $# -lt 1 ]; then  
  echo "USAGE: $0 [newick_tree_file] [bootstrap_threshold (optional; defaults to 75)]
        OUTPUT: Average_support Maximum_Support Minimum_support Number_of_Internal_Edges Number_of_High_Support_Edges"
  exit 1
fi
S=$2
if [ -z $S ] || [ $S -gt 100 ] || [ $S -lt 0 ]; then
	S=75
fi
for x in `cat $1`; do 
  echo $x| sed -e "s/[^)]*[);]\([0-9]*\)/\1 /g"|tr " " "\n"|awk '
    BEGIN {sum=0;num=0;min=100;max=0;high=0;}
          {if ($1 >=0 && $1 <=100) {
	      sum+=$1;num++; 
	      if ($1>max) {max=$1}; 
	      if($1<min) {min=$1};
	      if($1>= '$S') {high++};
	    }
          }
   END    {print sum/num " " max " " min " " num " " high}'
done
