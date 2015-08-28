#!/bin/bash

test $# == 1 || { echo USAGE: $0 file_with_newick_trees; exit 1; }

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

tmp=`mktemp`
cat $1| xargs -I@ sh -c 'echo -n "@" >'$tmp'; '$WS_GLB_BIN'/triplets.soda2103 fancy printTriplets '$tmp';'|python $WS_GLB_PUTIL/summarize.triplets.py

rm $tmp
