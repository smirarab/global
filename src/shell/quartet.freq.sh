#!/bin/bash

test $# == 1 || { echo USAGE: $0 file_with_newick_trees; exit 1; }

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

tmp=`mktemp`

for x in `cat $1`; do 
  echo -n "$x" >$tmp; 
  $WS_GLB_BIN/quart_bin fancy printQuartets $tmp;
done |sed -e "s/^.*: //" | python $WS_GLB_PUTIL/distance.py>$WS_GLB_RES/quartetDistance.txt ; 


rm $tmp;
