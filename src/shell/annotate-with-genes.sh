#!/bin/bash

set -e
set -x
set -o pipefail

test $# == 2 || echo USAGE: species_tree gene_trees
test $# == 2 || exit 1

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

## This script annotate the species_tree with support from gene_trees, collapsing branches below $THS support
## Depends on java, newick utilities, and dendropy < 3.18. Phylonet code is also used but is bundled

COUNT=false
THS=75

gt=$2
st=$1
tmp=`mktemp`

l=`cat $gt|wc -l`

#remove_internal_node_labels_from_tree.py $gt
nw_topology -I $gt > $gt.nobs
java -jar $WS_GLB_LIB/phylonet_v2_5_compat.jar compat $st $gt.nobs b 2>&1|tail -n1|tee $tmp
if [ $COUNT == "false" ]; then
  python $WS_GLB_PUTIL/normalize-bl.py $l - $tmp |tee $st.annotatedby.$gt
else
 sed -e "s/://g" -e "s/\.0//g" $tmp |tee $tmp.1
fi 

python $WS_GLB_PUTIL/remove_edges_from_tree.py $gt $THS - -strip-both
java -jar $WS_GLB_LIB/phylonet_v2_5_compat.jar compat $st $gt.$THS b 2>&1|tail -n1|tee $tmp
if [ $COUNT = false ]; then
 python $WS_GLB_PUTIL/normalize-bl.py $l - $tmp |tee $st.annotatedby.$gt.$ths
else 
 sed -e "s/://g" -e "s/\.0//g" $tmp |tee $tmp.2
fi 

if [ $COUNT = false ]; then
 cat $st.annotatedby.$gt $st.annotatedby.$gt.$THS > $tmp
 python $WS_GLB_PUTIL/merge_support_from_trees.py 0 $tmp $st.geneannotated.$gt
else
 cat $tmp.1 $tmp.2 > $tmp
 python $WS_GLB_PUTIL/merge_support_from_trees.py 0 $tmp $st.geneannotated.$gt.counts.tre
fi

rm $gt.nobs $tmp
