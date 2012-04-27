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

MAX_LENGTH = 20000
MAX_NNNs = 120
N_CHAR = "N"
N_SEQS= set(["Vitis" , "Carica", "Sorghum"])

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
    for file in locate("*.cds.original"):
        p = sub.Popen(['simplifyfasta.sh',file],stdout=sub.PIPE,stderr=sub.PIPE)
        output, errors = p.communicate()
        if errors is not None and errors != "":
            print errors
            sys.exit(1)
        outfile = open(file[0:-9],'w')
        filemaxlen = 0
        for line in output.split("\n"):
            if line.startswith(">"):
                seqName = line[1:]
            else:
                if (len(line) > filemaxlen):
                    filemaxlen = len(line)
                if ( len(line) > MAX_LENGTH ):
                    print "skipping %s from %s due to length: %d" %(seqName, file, len(line))
                    continue
                match = re.search(pattern,line)
                if  seqName[0:6] in N_SEQS and match is not None:
                    print "skipping %s from %s due to long Stretch of %s at position %d" %(seqName, file, N_CHAR, match.start())
                    continue
                outfile.write(">%s\n%s\n" %(seqName,line))         
        outfile.close()
        print >>sys.stderr, "%s %d" %(file,filemaxlen)