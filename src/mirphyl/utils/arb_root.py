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

    treeName = sys.argv[1]
    
    #cmd = 'find %s -name "%s" -print' % (treeDir,treeName)
    #print cmd
    #for file in os.popen(cmd).readlines():     # run find command        
    #    name = file[:-1]                       # strip '\n'                
    #    fragmentsFile=name.replace(treeName,"sequence_data/short.alignment");
    resultsFile="%s.rooted" % treeName
    
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    for tree in trees:
        n = tree.find_node_with_taxon_label("O")     
        tree.reroot_at_edge(n.edge, update_splits=False)
        #tree.reroot_at_midpoint(update_splits=False)
        
    trees.write(open(resultsFile,'w'),'newick',edge_lengths=False, internal_labels=False)