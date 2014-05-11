#!/lusr/bin/python
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

    treeName = sys.argv[1]
    
    resultsFile="%s.%s" % (treeName, "unrooted")
    trees = dendropy.TreeList.get_from_path(treeName, 'newick',rooted=True)    
    for tree in trees:
        tree.resolve_polytomies()
        tree.deroot()
        #tree.reroot_at_midpoint(update_splits=False)
    print "writing results to " + resultsFile        
    trees.write(open(resultsFile,'w'),'newick',write_rooting=False)
