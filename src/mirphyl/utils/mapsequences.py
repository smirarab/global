#! /usr/bin/env python
 
import os
import sys
import re

if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 4:
    sys.stderr.write("usage: %s [<tree-file-path>] [<map-file-path>] [<out-file-path>] [-rev]\n"%sys.argv[0])
    sys.exit(1)

QUOTEIN = False
IGNORE = True
QUOTEOUT = False
UNDEROUT= True

if QUOTEIN:
    pattern = re.compile("(?<=[,(])'([^']+)'(?=[,():])")
else:
    pattern = re.compile("(?<=[,(])([^(,:)]+)(?=[,():])")

 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)
src = open(src_fpath,"r")        
 
outfile = sys.argv[3]
if outfile == "-auto":
    outfile = "%s.longname.tre" %sys.argv[1]
dest_fpath = os.path.expanduser(os.path.expandvars(outfile))
dest = open(dest_fpath, "w")

map_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
mapfile = open(map_fpath, "r")

reverse = False
if len(sys.argv) == 5 and sys.argv[4] == "-rev":
    reverse = True

print("writing to file %s" %os.path.abspath(dest_fpath))

mapping = {}
for line in mapfile:
    m = line.replace("\n","").replace("\r","").split("\t")
    #print m
    if not reverse:
        mapping[m[1].split(" ")[0]] = m[0]
    else: 
        mapping[m[0].split(" ")[0]] = m[1]

def replace_func(m):
    repl = m.group(1)
    if m.group(1) in mapping:
        repl = mapping[m.group(1)]
    elif IGNORE:
        print("Ignoring", m.group(1))
    else:
        raise "Name %s not found in the mapping file." %m.group(1)
    if UNDEROUT:
        repl = repl.replace(' ','_')
    if QUOTEOUT:
        repl = "'%s'" % repl
    return repl 
for t in src:    
    #print "tree is",t
    t = pattern.sub(replace_func,t)
    dest.write(t)

dest.close()
