#!/lusr/bin/python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import os
import copy
''' roots the tree on the given outgroups. Input is:
-- first argument: a path to the tree file
-- second argument: a list of outgroups, separated by comma. 
-- third argument: (optional) -mrca
The script goes through the list of outgroups. 
If the outgroup is found in the tree, the tree is rooted at that outgroup.
Otherwise, the next outgroup in the list is used. 
Each element in the camma-delimited list is itself a + delimited list of taxa.
By default the script makes sure that the set of outgroups used are monophyletic
in the tree and roots the tree at the node leading to the clade represented by outgroups.
If outgroups are not monophyletic, the first one is used.
Using -mrca this monophyletic requirement can be relaxed, so that MRCA is always used. 
'''
if __name__ == '__main__':
    
    if len (sys.argv) < 2:
        print '''USAGE: %s [tree_file] [outgroups] [-mrca (optional)]

-- tree_file: a path to the newick tree file

-- outgroups: a list of outgroups, separated by comma.
The script goes through the list of outgroups. If the outgroup is found in the tree, 
the tree is rooted at that outgroup. Otherwise, the next outgroup in the list is used. 
Each element in the comma-delimited list is itself a + delimited list of taxa.
By default the script makes sure that this list of taxa are monophyletic
in the tree and roots the tree at the node leading to the clade represented 
by outgroups given in the + delimited list.
Alternatively, you can specify -m which will result in mid-point rooting.

Example: HUMAN,ANOCA,STRCA+TINMA first tries to root at HUMAN, if not present, 
tries to use ANOCA, if not present, tries to root at parent of STRCA and TINMA
which need to be monophyletic. If not monophyletic, roots at STRCA.

-- (optional) -mrca: using this option the mono-phyletic requirement is relaxed 
and always the mrca of the + delimited list of outgroups is used.
''' %sys.argv[0]
        sys.exit(1)
    treeName = sys.argv[1]

    outgroups = sys.argv[2].split(",")
    
    use_mrca = True if len(sys.argv) > 3 and sys.argv[3] == "-mrca" else False
    #cmd = 'find %s -name "%s" -print' % (treeDir,treeName)
    #print cmd
    #for file in os.popen(cmd).readlines():     # run find command        
    #    name = file[:-1]                       # strip '\n'                
    #    fragmentsFile=name.replace(treeName,"sequence_data/short.alignment");
    resultsFile="%s.rooted"%treeName[:-9] if treeName.endswith("unrooted") else "%s.rooted" % treeName
    print "Reading input trees ..."
    trees = dendropy.TreeList.get_from_path(treeName, 'newick',rooted=True)
    i = 0;    
    for tree in trees:        
        i+=1
        oldroot = tree.seed_node
        print "Tree %d:" %i
        if outgroups[0] == "-m":            
            print "Midpoint rooting ... "
            tree.reroot_at_midpoint(update_splits=False)
        else:             
            mrca = None
            for outgroup in outgroups:  
                outs = outgroup.split("+")
                outns = []                    
                for out in outs:          
                    n = tree.find_node_with_taxon_label(out)
                    if n is None:
                        continue            
                    outns.append(n.taxon)  
                if len (outns) != 0:
                    # Find an ingroup and root the tree there
                    for n in tree.leaf_iter():
                        if n.taxon not in outns:
                            ingroup=n
                            break
                    # print "rerooting at ingroup %s" %ingroup.taxon.label
                    '''reroot at an ingroup, so that outgroups form monophyletic groups, if possible'''
                    tree.reroot_at_edge(ingroup.edge, update_splits=True,length1=ingroup.edge.length/2,length2=ingroup.edge.length/2)
                    mrca = tree.mrca(taxa=outns)
            #if not mono-phyletic, then use the first
            if not use_mrca and len (mrca.leaf_nodes()) != len(outns):
                print "selected set is not mono-phyletic. Using %s instead. " %outns[0]
                mrca = tree.find_node_with_taxon_label(outs[0])
                break                    
            if mrca is None:
                raise KeyError("Outgroups not found: %s" %outgroups)
            if mrca.parent_node is None:
                print "Already rooted at the root."
                #print "rerooting on %s" % [s.label for s in outns]
                #tree.reroot_at_midpoint()
            elif mrca.edge.length is not None:
                tree.reroot_at_edge(mrca.edge, update_splits=False,length1=mrca.edge.length/2,length2=mrca.edge.length/2)        
            else:
                tree.reroot_at_edge(mrca.edge, update_splits=False)
        '''This is to fix internal node labels when treated as support values''' 
        while oldroot.parent_node != tree.seed_node:
            oldroot.label = oldroot.parent_node.label
            oldroot = oldroot.parent_node
        oldroot.label = oldroot.sister_nodes()[0].label    
            #tree.reroot_at_midpoint(update_splits=False)            
    print "writing results to %s" %resultsFile        
    trees.write(open(resultsFile,'w'),'newick',edge_lengths=True, internal_labels=True)