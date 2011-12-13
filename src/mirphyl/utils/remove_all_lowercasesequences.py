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
    resultsFile="%s.fixed" % treeName
    
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    filter = lambda node: True if (node.taxon is not None and node.taxon.label.startswith('seq')) else False
    for tree in trees:
        nodes = tree.get_node_set(filter)
        tree.prune_taxa([n.taxon for n in nodes])
        tree.deroot()
        #tree.reroot_at_midpoint(update_splits=False)
        
    trees.write(open(resultsFile,'w'),'newick',write_rooting=False)