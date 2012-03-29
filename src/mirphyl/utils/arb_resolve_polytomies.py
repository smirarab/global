#!/lusr/bin/python2.7
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys


if __name__ == '__main__':

    treeName = sys.argv[1]
    
    #cmd = 'find %s -name "%s" -print' % (treeDir,treeName)
    #print cmd
    #for file in os.popen(cmd).readlines():     # run find command        
    #    name = file[:-1]                       # strip '\n'                
    #    fragmentsFile=name.replace(treeName,"sequence_data/short.alignment");
    resultsFile="%s.resolved" % treeName
    
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    for tree in trees:            
        print "."    
        tree.resolve_polytomies()     
    
    trees.write(open(resultsFile,'w'),'newick',edge_lengths=True)
