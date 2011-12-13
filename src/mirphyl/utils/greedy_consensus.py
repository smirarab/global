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
        sys.stderr.write("usage: %s [<trees-file-path>] [threshold] [<out-file-path>]\n"%sys.argv[0])
        sys.exit(1)
    
    treeName = sys.argv[1]
    threshold = float(sys.argv[2])
    resultsFile = sys.argv[3]

   
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    con_tree = trees.consensus(min_freq=threshold)     
        #tree.reroot_at_edge(n.edge, update_splits=False)
        #tree.reroot_at_midpoint(update_splits=False)
        
    con_tree.write(open(resultsFile,'w'),'newick',write_rooting=False)
    