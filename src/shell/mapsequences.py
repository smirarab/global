#! /usr/bin/env python
 
import os
import sys
 
if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 4:
    sys.stderr.write("usage: %s [<tree-file-path>] [map-file-path] [<out-file-path>]\n"%sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)
src = open(src_fpath,"r")        
 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[3]))
dest = open(dest_fpath, "w")

map_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
mapfile = open(map_fpath, "r")

mapping = {}
for line in mapfile:
    m = line.replace("\n","").replace("\r","").split("\t")
    mapping[m[1]] = m[0]


for t in src:
    n = t
    for o,m in mapping.items():
        n=n.replace(o,m)
    dest.write(n)

dest.close()
