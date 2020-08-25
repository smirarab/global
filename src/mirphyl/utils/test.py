'''
Created on Mar 12, 2016

@author: smirarab
'''

import dendropy
from dendropy import treesim
import random
from dendropy.dataobject.taxon import Taxon
from dendropy.dataobject.tree import Tree, Node
import math

def graft(t1,t2s,childnames):
    ndrands = []
    for t in t2s:
        nr = t1.seed_node
        while not nr.parent_node or nr.is_leaf(): 
            nr = random.choice(t1.nodes())
        ndrands.append(nr)
    for (t2,childname) in zip(t2s,childnames):
        nd_random = ndrands.pop()
        l = nd_random.edge.length
        #print l
        mid_random = nd_random.parent_node.new_child(edge_length=l/2)
        nd_random.parent_node.remove_child(nd_random)
        mid_random.add_child(nd_random,edge_length = l/2)
        #print(mid_random.as_newick_string())
        mid_random.add_child(t2.seed_node,edge_length=l/2)
        t2.seed_node.taxon = Taxon(label = childname)
    #print(mid_random.as_newick_string())

#        0    1    2    3    4    5      6    7
nodes=["25","70","27","181","58","105","103","82"]
levels=[.8, .25, .3,   .15, .13,  .1,   0.05, .10]

trs = [treesim.birth_death(birth_rate=100.0/l, 
                                  death_rate=100.0/l,
                                  birth_rate_sd=50,
                                  death_rate_sd=50,
                                  taxon_set=dendropy.TaxonSet([n+"-"+str(y) for y in xrange(1,int(math.sqrt(700*l)))]),
                                  max_time=0.1) for (n,l) in zip(nodes,levels)]
print ("simulated")

graft(trs[5],[trs[6]],[nodes[6]])
graft(trs[4],[trs[5]],[nodes[5]])
graft(trs[2],[trs[3],trs[4]],[nodes[3],nodes[4]])
graft(trs[1],[trs[7]],[nodes[7]])
graft(trs[0],[trs[2],trs[1]],[nodes[2],nodes[1]])

tree =trs[0]

md = tree.max_distance_from_root()

trs[0].write_to_path("/Users/smirarab/Research/proposals/2015-CNIHR/test.tre",schema='newick')

print(trs[0])