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
-- second argument: a list of outgroups, separated by camma. 
-- third argument: (optional) -mrca
The script goes through the list of outgroups. 
If the outgroup is found in the tree, the tree is rooted at that outgroup.
Otherwise, the next outgroup in the list is used. 
Each element in the camma-delimited list is itself a + delimited list of taxa.
By default the script makes sure that this list of taxa are mono-phyletic
in the tree (if not, an error is generated) and rootss the tree at the parent
of these taxa.
Using -mrca this mono-phyletic requirement can be overwritten. 
'''
if __name__ == '__main__':
    
    if len (sys.argv) < 2:
	print '''USAGE: %s [tree_file] [outgroups] [-mrca (optional)]\n
-- tree_file: a path to the newick tree file\n
-- outgroups: a list of outgroups, separated by camma.
The script goes through the list of outgroups. 
If the outgroup is found in the tree, the tree is rooted at that outgroup.
Otherwise, the next outgroup in the list is used. 
Each element in the camma-delimited list is itself a + delimited list of taxa.
By default the script makes sure that this list of taxa are mono-phyletic
in the tree (if not, an error is generated) and roots the tree at the parent
of the outgroups given in the + delimited list.\n
Example: HUMAN,ANOCA,STRCA+TINMA first tries to root at HUMAN, if not present, 
tries to use ANOCA, if not present, tries to root at parent of STRCA and TINMA
which need to be mono-phyletic.\n
-- (optional) -mrca: using this option the mono-phyletic
requirement is relaxed.
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
    print "writing results to %s" %resultsFile
    trees = dendropy.TreeList.get_from_path(treeName, 'newick',rooted=True)
    for tree in trees:
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
                mrca = tree.mrca(taxa=outns)
		#if not mono-phyletic, then use the first
		print len(outns)
		print use_mrca
		print len (mrca.leaf_nodes())
		if not use_mrca and len (mrca.leaf_nodes()) == len(outns):
		    print "selected set is not mono-phyletic. Using %s " %outns[0]
		    mrca = tree.find_node_with_taxon_label(outs[0])
                break                    
        if mrca is None:
            raise KeyError("Outgroups not found: %s" %outgroups)
	
 
	if mrca.parent_node is None:
	    print ("Already rooted at the root.")
        #print "rerooting on %s" % [s.label for s in outns]
        #tree.reroot_at_midpoint()
	elif mrca.edge.length is not None:
	        tree.reroot_at_edge(mrca.edge, update_splits=False,length1=mrca.edge.length/2,length2=mrca.edge.length/2)        
	else:
		tree.reroot_at_edge(mrca.edge, update_splits=False)
        #tree.reroot_at_midpoint(update_splits=False)
        
    trees.write(open(resultsFile,'w'),'newick',edge_lengths=True, internal_labels=False)
