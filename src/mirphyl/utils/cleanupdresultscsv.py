'''
Created on Jul 21, 2011

@author: smirarab
'''
import sys

choose= {"run":["raxml_clustalw","raxml_muscle","raxml_mafft","raxml_cobalt"],
         "run2":["raxml_probcons","raxml_prank","raxml_satchmo"],
         "runfasttree":["fasttree_clustalw","fasttree_mafft","fasttree_cobalt"],
         "runopal":"*",
	     "runsate":"*",
	     "runfasttreewag":[]
         }

if __name__ == '__main__':
    out = open(sys.argv[2],"w")
    inf = open(sys.argv[1]).readlines()
    out.write(inf[0])
    for line in inf[1:]:
        l = line.split()
        if choose[l[0]] == "*" or l[3] in choose[l[0]]:
            l = l[1:]
            out.write(" ".join(l)+"\n")
    out.close()
