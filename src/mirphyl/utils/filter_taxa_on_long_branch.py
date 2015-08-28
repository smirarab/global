#!/usr/bin/env python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
LIMIT = 25

def meanstdv(x):
    from math import sqrt
    n, mean, std = len(x), 0, 0
    for a in x:
        mean = mean + a
    mean = mean / float(n)
    for a in x:
        std = std + (a - mean)**2
    std = sqrt(std / float(n-1))
    return mean, std

if __name__ == '__main__':

    treeName = sys.argv[1]
    
    resultsFile="%s.%dfold.longbranch.removed" % (treeName,LIMIT)
            
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')    
    for tree in trees:
        N = len(tree.taxon_set)
        print "%s" %treeName,
        elen = {}
        for edge in tree.postorder_edge_iter():
            elen[edge] = edge.length
        
        elensort = sorted([float(x) for x in elen.values() if x is not None])
        n = len(elensort)
        mid = elensort[n/2]
        l = mid * LIMIT
        torem=[]
        for k,v in elen.items():            
            if v > l:
                #decide which side is the shorter head of the stick (has fewer taxa)
                if len(k.head_node.leaf_nodes()) < N/2:
                    r = [n.taxon for n in k.head_node.leaf_nodes()]
                else:
                    r = [n.taxon for n in tree.leaf_nodes() if n not in k.head_node.leaf_nodes()]       
                #print r             
                torem.append(r)

        torem2=[]
        for r in torem: 
            nl = set(r)
            skipthis = False
            # figure if this is already removed
            for o in torem2:
                if set(o).issuperset(nl):
                    skipthis = True
            if not skipthis:
                if len(r) != -1:
                    torem2.append(r)
                    print [n.label for n in r],
        print        
        for r in torem2:     
            #print [x.taxon.label for x in n.leaf_nodes()], tree.seed_node, n            
            #tree.prune_taxa(r)
            pass
        #nodes = tree.get_node_set(filter)
        #tree.prune_taxa([n.taxon for n in nodes])
        #tree.deroot()
        #tree.reroot_at_midpoint(update_splits=False)
        
    trees.write(open(resultsFile,'w'),'newick',write_rooting=False)
