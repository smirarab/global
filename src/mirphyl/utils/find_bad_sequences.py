#!/lusr/bin/python
'''
Created on Jul 21, 2011

@author: smirarab
'''
import sys
import os
import fnmatch
import subprocess as sub
import re

MAX_LENGTH = 6666
MAX_NNNs = 40
N_CHAR = "X"
N_SEQS= set(["Vitvi1", "Carpa1", "Sorbi1"])

pattern = re.compile("%s{%d}" %(N_CHAR,MAX_NNNs))

def locate(pattern, root=os.curdir):
    '''Locate all files matching supplied filename pattern in and below
    supplied root directory.'''
    if not os.path.exists(root):
        raise RuntimeError ("path not found: %s" % root)    
    for path, dirs, files in os.walk(os.path.abspath(root)):
        for filename in fnmatch.filter(files, pattern):
            yield os.path.join(path, filename)

if __name__ == '__main__':
    for file in locate("*.pep"):
        seqLen_p = {}
        seqLen_c = {}
        p = sub.Popen(['simplifyfasta.sh',file],stdout=sub.PIPE,stderr=sub.PIPE)
        output, errors = p.communicate()
        if errors is not None and errors != "":
            print errors
            sys.exit(1)
        for line in output.split("\n"):
            if line.startswith(">"):
                seqName = line[1:]
            else:
                seqLen_p[seqName] = len(line)     
        
        filec = re.sub("pep", "cds", file)
        filec = re.sub("pep", "cds", filec)
        p = sub.Popen(['simplifyfasta.sh',filec],stdout=sub.PIPE,stderr=sub.PIPE)
        output, errors = p.communicate()
        if errors is not None and errors != "":
            print errors
            sys.exit(1)
        for line in output.split("\n"):
            if line.startswith(">"):
                seqName = line[1:]
            else:
                seqLen_c[seqName] = len(line)    
        
        for seq in seqLen_c.keys():
            if seqLen_p[seq]*3 - seqLen_c[seq] >6:
                print "%s: %s (%d,%d)" %(re.sub("^.*cds\/","",filec),seq,seqLen_p[seq]*3 ,seqLen_c[seq])
