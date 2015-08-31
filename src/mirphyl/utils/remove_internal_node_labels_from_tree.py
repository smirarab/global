#!/usr/bin/env python
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
            
    resultsFile="%s.nobs" % treeName if len (sys.argv) == 2 else sys.argv[2]
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    for tree in trees:
        for n in tree.internal_nodes():            
            n.label = None    
                    
    trees.write(open(resultsFile,'w'),'newick',write_rooting=False)
