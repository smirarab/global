#!/lusr/bin/python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import os
import copy

if __name__ == '__main__':

    if ("--help" in sys.argv) or ("-?" in sys.argv) or ("-h" in sys.argv) or len(sys.argv) < 4:
        sys.stderr.write("usage: %s [threshold] [<out-file-path>] [<trees-file-paths>] \n"%sys.argv[0])
        sys.exit(1)
    
    threshold = float(sys.argv[1])
    resultsFile = sys.argv[2]

    trees = dendropy.TreeList()
   
    for fpath in sys.argv[3:]:
        trees.read_from_path(fpath, 'newick')

    con_tree = trees.consensus(min_freq=threshold)     
        #tree.reroot_at_edge(n.edge, update_splits=False)
        #tree.reroot_at_midpoint(update_splits=False)
        
    for e in con_tree.postorder_node_iter():
        if hasattr(e,"support"):
    	    e.support=e.support*100
            e.label=str(e.support)

    con_tree.write(open(resultsFile,'w'),'newick',write_rooting=False)
    
