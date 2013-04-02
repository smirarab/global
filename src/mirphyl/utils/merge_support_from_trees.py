#! /usr/bin/env python

import dendropy
import os
import sys
import re


if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 3:
    sys.stderr.write("usage: %s [<tree-file-path>] [<out-file-path>]\n" % sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)
src = open(src_fpath, "r")        
 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
dest = open(dest_fpath, "w")

print "Will write to file %s" % os.path.abspath(dest_fpath)


trees = dendropy.TreeList()
for tree_file in [src_fpath]:
    trees.read_from_path(
            tree_file,
            'newick')

#for tree in trees:
#    n = tree.find_node_with_taxon_label("STRCA")
#    tree.reroot_at_edge(n.edge, update_splits=False)

#con_tree = trees.consensus()
con_tree = dendropy.Tree(trees[0])
print con_tree.as_string('newick')
for edge in con_tree.postorder_edge_iter():
    taxa = [n.taxon for n in edge.head_node.leaf_nodes()]
    if len(taxa) == 1:
        continue
    sum = ""
    for tre in trees:
        mrca = tre.mrca(taxa=taxa)
        if mrca.label is not None:
            newlab = mrca.label if len(mrca.leaf_nodes()) == len(taxa) else "NA"
            sum = newlab if sum == "" else "%s,%s" % (sum, newlab)
    sum = "*" if sum == "100,100" else sum
    edge.head_node.label = sum
    edge.label = sum
con = con_tree.as_string('newick')
dest.write(con)

dest.close()
print con_tree.as_string('newick')
