#!/usr/bin/env python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import os
import copy
import os.path

if __name__ == '__main__':

    if len(sys.argv) < 4: 
        print >>sys.stderr,  "USAGE: denominator [postfix|-|--] treefiles"
        sys.exit(1)
        
    denom = float(sys.argv[1])
    stdout = False
    if sys.argv[2] == "-":
        resultsFile = sys.stdout
        stdout = True
    elif sys.argv[2] == "--":
        postfix = "blen"
    else:
        postfix = sys.argv[2]
    
    c={}
    for treeName in sys.argv[3:]:
        if not stdout:
            resultsFile=open("%s.%s" % (treeName, postfix),'w')
        trees = dendropy.TreeList.get_from_path(treeName, 'newick',rooted=True)
        for tree in trees:
            for e in tree.postorder_edge_iter():
                e.head_node.label = "{:.0f}".format((e.length / denom * 100)) if e.length is not None else None
                e.length = None
        print >>sys.stderr, "writing results to " + resultsFile.name        
        trees.write(resultsFile,'newick',write_rooting=False)
