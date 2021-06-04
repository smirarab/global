#!/usr/bin/env python

import sys

if __name__ == '__main__':
    if ("--help" in sys.argv) or ("-?" in sys.argv) or ("-h" in sys.argv) or len(sys.argv) < 4:
        sys.stderr.write("usage: %s <filter|keep> <alignment file> <comma delimitated list of names or - to read from stdin>\n"%sys.argv[0])
        sys.exit(1)

    taxa=set()
    if sys.argv[3] == "-":
        taxa.update(x.strip() for x in sys.stdin.readlines())
    else:
        taxa.update(sys.argv[3].split(','))
    #print taxa
    
    keep=False
    for l in open(sys.argv[2],'r'):
        if l.startswith(">"):
            if l[1:-1] in taxa:
                keep=True if sys.argv[1] == "keep" else False
            else:
                keep=False if sys.argv[1] == "keep" else True
        if keep:
            print l,
