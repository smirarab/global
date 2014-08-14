#!/bin/bash

set -e
set -x
set -o pipefail

echo USAGE: species_tree gene_trees

COUNT=false

gt=$2
st=$1
tmp=`mktemp`

l=`cat $gt|wc -l`

#remove_internal_node_labels_from_tree.py $gt
nw_topology -I $gt > $gt.nobs
java -jar /projects/sate7/tools/bin/phylonet_v2_5_compat.jar compat $st $gt.nobs b 2>&1|tail -n1|tee $tmp
if [ $COUNT == "false" ]; then
  normalize-bl.py $l - $tmp |tee $st.annotatedby.$gt
else
 sed -e "s/://g" -e "s/\.0//g" $tmp |tee $tmp.1
fi 

remove_edges_from_tree.py $gt 75 - -strip-both
java -jar /projects/sate7/tools/bin/phylonet_v2_5_compat.jar compat $st $gt.75 b 2>&1|tail -n1|tee $tmp
if [ $COUNT = false ]; then
 normalize-bl.py $l - $tmp |tee $st.annotatedby.$gt.75
else 
 sed -e "s/://g" -e "s/\.0//g" $tmp |tee $tmp.2
fi 

if [ $COUNT = false ]; then
 cat $st.annotatedby.$gt $st.annotatedby.$gt.75 > $tmp
 merge_support_from_trees.py 0 $tmp $st.geneannotated.$gt
else
 cat $tmp.1 $tmp.2 > $tmp
 merge_support_from_trees.py 0 $tmp $st.geneannotated.$gt.counts.tre
fi

rm $gt.nobs $tmp
