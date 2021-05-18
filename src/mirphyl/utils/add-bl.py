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

    if len(sys.argv) < 3: 
        print("USAGE: [postfix|-|--] treefile")
        sys.exit(1)
    stdout = False
    if sys.argv[1] == "-":
        resultsFile = sys.stdout
        stdout = True
    elif sys.argv[1] == "--":
        postfix = "blen"
    else:
        postfix = sys.argv[1]
    
    c={}
    for treeName in sys.argv[2:]:
        if not stdout:
            resultsFile=open("%s.%s" % (treeName, postfix),'w')
        trees = dendropy.TreeList.get_from_path(treeName, 'newick')
        for tree in trees:
            for e in tree.postorder_edge_iter():
                if not e.length:
                    e.length = 1
        sys.stderr.write("writing results to " + resultsFile.name + "\n")        
        trees.write(file=resultsFile,schema='newick')
