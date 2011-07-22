#! /usr/bin/env python
 
import os
import sys
 
if ("--help" in sys.argv) or ("-?" in sys.argv):
    sys.stderr.write("usage: $0 [<fasta-file-path>] [<out-file-path>] [map-file-path]\n")
    sys.exit(1)
 
if len(sys.argv) < 2:
    src = sys.stdin
else:
    src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
    if not os.path.exists(src_fpath):
        sys.stderr.write('Not found: "%s"' % src_fpath)
    src = open(src_fpath,"rb")        
 
if len(sys.argv) < 3:
    dest = sys.stdout
else:
    dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
    dest = open(dest_fpath, "w")

if len(sys.argv) < 4:
    mapping = sys.stderr
else:
    map_fpath = os.path.expanduser(os.path.expandvars(sys.argv[3]))
    mapping = open(map_fpath, "w")

 
i = 0
for l in src:
    if l.startswith(">"):
        realname = l[1:]
        assignedname = "SEQ%d" %i
        dest.write(">%s\n"%assignedname)
        mapping.write("%s\t%s" %(assignedname,realname))
        i += 1
    else:
        dest.write(l)
dest.close()
mapping.close()
