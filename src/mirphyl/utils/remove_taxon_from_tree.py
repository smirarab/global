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

    if len(sys.argv) < 3: 
        print("USAGE: treefile species_list_file [output]")
        sys.exit(1)
    treeName = sys.argv[1]
    #sample = open(sys.argv[2])
    included = [s for s in sys.argv[2:-1]]
    resultsFile="%s.%s" % (treeName, "renamed")
    trees = dendropy.TreeList.get_from_path(treeName, 'newick',preserve_underscores=True)
    filt = lambda node: True if (node.taxon is not None and node.taxon.label in included) else False
    for tree in trees:
        tree.filter_leaf_nodes(filt)
        tree.deroot()
        #tree.reroot_at_midpoint(update_splits=False)
    trees.write(file=sys.stdout, schema='newick', suppress_rooting=True)
