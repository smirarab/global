#! /usr/bin/env python

import dendropy
import os
import sys
import re


if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 4:
    sys.stderr.write("usage: %s [treshold] [<tree-file-path>] [<out-file-path>]\n" % sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)
src = open(src_fpath, "r")        
 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[3]))
dest = open(dest_fpath, "w")

threshold = float(sys.argv[1])

print "Will write to file %s" % os.path.abspath(dest_fpath)


trees = dendropy.TreeList()
for tree_file in [src_fpath]:
    trees.read_from_path(tree_file,'newick')

#for tree in trees:
#    n = tree.find_node_with_taxon_label("STRCA")
#    tree.reroot_at_edge(n.edge, update_splits=False)

con_tree = trees.consensus(min_freq=threshold)
#con_tree = dendropy.Tree(trees[0])
print con_tree.as_string('newick')
for edge in con_tree.postorder_edge_iter():
    taxa = [n.taxon for n in edge.head_node.leaf_nodes()]
    if len(taxa) == 1:
        continue
    labels=[]
    for tre in trees:
        mrca = tre.mrca(taxa=taxa)
        labels.append(str(int(round(float(mrca.label)))) if mrca.label is not None and len(mrca.leaf_nodes()) == len(taxa) else "NA")
    fl = "*" if all(x=="100" for x in labels) else (None if all(x=="NA" for x in labels) else ",".join(labels))
    print labels,fl
    edge.head_node.label = fl
    edge.label = fl
con = con_tree.as_string('newick')
dest.write(con)

dest.close()
print con_tree.as_string('newick')
