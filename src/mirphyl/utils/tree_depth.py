#!/lusr/bin/python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import re
import math

if __name__ == '__main__':

    treeStrings = open(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.readline()[0:-1]).readlines()
    trees = []
    for tree in treeStrings:
        trees.append(re.sub(":[^),]*", ":.1", tree))
    
    #cmd = 'find %s -name "%s" -print' % (treeDir,treeName)
    #print cmd
    #for file in os.popen(cmd).readlines():     # run find command        
    #    name = file[:-1]                       # strip '\n'                
    #    fragmentsFile=name.replace(treeName,"sequence_data/short.alignment");
        
        
    for t in trees:
        tree = dendropy.TreeList.get_from_string(t,"newick")[0]
        tree.reroot_at_midpoint(update_splits=False)
        print tree.seed_node.distance_from_tip()*10, len(tree.taxon_set), math.log(len(tree.taxon_set),2) 
        