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
    for m in [0.2, 0.5, 2 ,5]:
        treeName = sys.argv[1]
        names=["veryshort","short","medium","long","verylong"]
        brackets = [x/m for x in [0,0.1,.25,.625,1.5625,1000] ]
        ranges = zip(brackets,brackets[1:])
        c={}
        t = dendropy.TreeList.get_from_path(treeName, 'newick',rooted=True)[0]
        outtrees = [dendropy.Tree(t) for x in ranges]
        for i,tree in enumerate(outtrees):
            for n in tree.postorder_internal_node_iter():
                e=n.edge
                if not ranges[i][0] < e.length < ranges[i][1]:
                    e.collapse()
            #tree.reroot_at_midpoint(update_splits=False)
            resultsFile = "%s.%s.%f" %(treeName,names[i],m)
            print "writing results to " + resultsFile        
            tree.write(open(resultsFile,'w'),'newick',write_rooting=False)
