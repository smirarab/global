#! /usr/bin/env python
 
import os
import sys
 
if ("--help" in sys.argv) or ("-?" in sys.argv):
    sys.stderr.write("usage: degap.py [<fasta-file-path>] [<out-file-path>]\n")
    sys.exit(1)
 
if len(sys.argv) < 2:
    src = sys.stdin
else:
    src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
    if not os.path.exists(src_fpath):
        sys.stderr.write('Not found: "%s"' % src_fpath)
    src = open(src_fpath)        
 
if len(sys.argv) < 3:
    dest = sys.stdout
else:
    dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
    dest = open(dest_fpath, "w")
 
lines = src.readlines()
for i in lines:
    i = i.replace("-", "")
    if i: 
	dest.write(i)
