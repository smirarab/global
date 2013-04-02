#! /usr/bin/env python

import dendropy
import os
import sys
import re


if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 3:
    sys.stderr.write("usage: %s [<out-file-path>] [TREE File 1] [TREE File 2] ...\n"%sys.argv[0])
    sys.exit(1)
 

 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
dest = open(dest_fpath, "w")

print "Will write to file %s" %os.path.abspath(dest_fpath)

trees = dendropy.TreeList()
    
for fpath in sys.argv[2:]:
    src_fpath = os.path.expanduser(os.path.expandvars(fpath))
    if not os.path.exists(src_fpath):
        sys.stderr.write('Not found: "%s"' % src_fpath)
    src = open(src_fpath,"r")
    tree_str = "".join(line for line in src if not line.lstrip().startswith("tree ") or line.find("tree mpest")>=0)
    if tree_str.find("tree mpest") < 0:
        continue              
    print tree_str
    
    trees.read_from_string(tree_str, 'nexus')

print len(trees)

con_tree = trees.consensus(min_freq=0, trees_splits_encoded=False)
con = con_tree.as_string('newick')
dest.write(con)

dest.close()
