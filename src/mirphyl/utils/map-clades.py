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

    if len(sys.argv) < 2: 
        print "USAGE: treefile [output]"
        sys.exit(1)
    treeName = sys.argv[1]
    if len(sys.argv ) == 3:
        resultsFile=sys.argv[2]
    else:
        resultsFile="%s.%s" % (treeName, "relabelled")
    
    c={}
    for x in open("mapping"):
       c[x.split()[1]] = x.split()[0]
    trees = dendropy.TreeList.get_from_path(treeName, 'newick',rooted=True)
    for tree in trees:
        for n in tree.postorder_node_iter():
            if n.is_leaf():
                n.label="{"+c.get(n.taxon.label,"missing")+"}"
                n.taxon.label=n.taxon.label+n.label
            else:
                n.label=n.child_nodes()[0].label if n.child_nodes()[0].label == n.child_nodes()[1].label or n.child_nodes()[1].label =="{missing}" else n.child_nodes()[1].label if  n.child_nodes()[0].label =="{missing}" else ""
        #tree.reroot_at_midpoint(update_splits=False)
    print "writing results to " + resultsFile        
    trees.write(open(resultsFile,'w'),'newick',write_rooting=False)
