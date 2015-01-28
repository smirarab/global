#! /usr/bin/env python
 
import os
import sys
import re
import dendropy


if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 3:
    sys.stderr.write("usage: %s [<tree-file-path>] [<out-file-path>] [mb/none]\n"%sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
if not os.path.exists(src_fpath):
    sys.stderr.write("Not found: \"%s\"" % src_fpath)      
 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))

print "writing to file %s" %os.path.abspath(dest_fpath)

trees = dendropy.TreeList.get_from_path(src_fpath, "nexus")

if sys.argv[3] == "mb":
  for tre in trees:
     for n in tre.postorder_node_iter():
         if n.comments:
            n.label = n.comments[0].split(',')[4].split("=")[1].strip('"')

trees.write_to_path(dest_fpath, "newick",write_rooting=False)
