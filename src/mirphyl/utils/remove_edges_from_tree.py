#!/lusr/bin/python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import os
import copy

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
    
if __name__ == '__main__':

    treeName = sys.argv[1]
    
    #cmd = 'find %s -name "%s" -print' % (treeDir,treeName)
    #print cmd
    #for file in os.popen(cmd).readlines():     # run find command        
    #    name = file[:-1]                       # strip '\n'                
    #    fragmentsFile=name.replace(treeName,"sequence_data/short.alignment");
            
    resultsFile="%s.contracted" % treeName if len (sys.argv) < 3 else sys.argv[2]
    t = 75 if len (sys.argv) < 4 else float(sys.argv[3])    
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    filt = lambda edge: False if (edge.label is None or (is_number(edge.label) and float(edge.label) >= t)) else True
    for tree in trees:
        for n in tree.internal_nodes():
            if n.label is not None:
                n.label = float (n.label)
                n.edge.label = n.label
                #print n.label
                #n.label = round(n.label/2)   
        edges = tree.get_edge_set(filt)
        for e in edges:
            e.collapse()
        #tree.reroot_at_midpoint(update_splits=False)
        
    trees.write(open(resultsFile,'w'),'newick',write_rooting=False)
