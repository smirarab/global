#! /usr/bin/env python
'''
Created on Jul 19, 2011

@author: smirarab
'''
import sys
import subprocess as sub
sys.path.insert(0,'%s/../..' %sys.path[0])
from mirphyl.setup import HOME

if __name__ == '__main__':
    if len(sys.argv) < 3:
            print "usage: %s referencetree estimatedtree [outputfile]" % sys.argv[0]
            sys.exit(1)
    
    SHOME = "%s/tools/tree_comp_morgan/" % HOME
    cmd = ['perl','-I',SHOME,'%s/CompareTree.pl'%SHOME,'-tree',sys.argv[1],'-versus',sys.argv[2]]
    p = sub.Popen(cmd, stdout=sub.PIPE, stderr=sub.PIPE)
    output, err = p.communicate()
    fields = err.split()
    (open(sys.argv[3],"w") if len(sys.argv) > 3 else sys.stdout
     ).write("\n".join(                      
                      ["NUM_SPLITS %s" %fields[4],
                       "MISSING_SPLITS %s" %(str(int(fields[4])-int(fields[2]))),
                       "FN %s" %(str(1-float(fields[6])))
                       ])
             +"\n")
