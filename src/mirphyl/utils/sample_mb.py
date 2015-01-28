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
from dendropy import TreeList

if __name__ == '__main__':

    if len(sys.argv) < 4: 
        print "USAGE: count [output|-] treefile*"
        sys.exit(1)
    
    count= int(sys.argv[1])
    out=open(sys.argv[2],'w') if sys.argv[2] != "-" else sys.stdout 
    c={}
    trees = None
    for treeName in sys.argv[3:]:
        a = dendropy.TreeList.get_from_path(treeName, 'nexus',rooted=True, tree_offset=200)
        if trees:
            trees.append(a)
        else:
            trees = a
    import random
    samples = TreeList(random.sample(trees,count))
    samples.write(out,'newick',write_rooting=False)
    if out != sys.stdout:
        out.close()
