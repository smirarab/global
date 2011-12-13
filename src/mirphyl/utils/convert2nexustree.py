#! /usr/bin/env python
 
import os
import sys
import re


if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 3:
    sys.stderr.write("usage: %s [<tree-file-path>] [<out-file-path>]\n"%sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)
src = open(src_fpath,"r")        
 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
dest = open(dest_fpath, "w")

print "writing to file %s" %os.path.abspath(dest_fpath)

mapping = {}

dest.write("#NEXUS\n\n");
dest.write("BEGIN DATA;\n");
dest.write("BEGIN TREES;\n");
    
i=0
for t in src:    
    tr = "\ttree \t T%d = %s" %(i,t)
    i += 1
    dest.write(tr)

dest.write("\nEND;\n");
dest.write("END;\n");
dest.close()
