#!/bin/bash

dir=$1
f=$2
x=$3
supp=$4

if [ "$supp" == "-" ]; then 
  temp=$dir/$x/$f
else
  temp=`mktemp`
  $WS_HOME/global/src/mirphyl/utils/remove_edges_from_tree.py $dir/$x/$f $supp $temp -strip-both
fi

$WS_HOME/global/src/shell/compare.triplet.dist.sh $temp `ls $dir/*/$f`| sed -e "s/"$dir."/"$x" /g" -e "s/\/[^ ]* / /g"
