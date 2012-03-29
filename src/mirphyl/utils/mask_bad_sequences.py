#!/lusr/bin/python
'''
Created on Jul 21, 2011

@author: smirarab
'''
import sys
import subprocess as sub
import re

if __name__ == '__main__':
    
    annotationFile = sys.argv[1]
    geneFileNamePattern = sys.argv[2]
    MISSING_CHAR = sys.argv[3]
    multiplyBy = 1
    if (len(sys.argv) > 3):
        multiplyBy = int(sys.argv[4])
        
    gene = ''
    abePerGene = {}
    geneSanityCheckCount = 0
    for line in open(annotationFile).readlines():
        l = line.split('\t')
        if l[0] != gene and gene != '':
            print "Clean up for alignment: " + gene
            file = geneFileNamePattern.replace("{gene}", gene)
            p = sub.Popen(['simplifyfasta.sh',file],stdout=sub.PIPE,stderr=sub.PIPE)
            output, errors = p.communicate()
            if errors is not None and errors != "":
                print errors
                sys.exit(1)
            outfile = open("%s.removed" %(file),'w')

            checkcount = 0
            aberrants = []
            for line in output.split("\n"):
                if line.startswith(">"):
                    aberrants = abePerGene.get(line[1:].split(" ")[0],[])
                    outfile.write(line+"\n")
                else:
                    for ab in aberrants:
                        start = ab["start"]
                        end  = ab["end"]
                        chunks = [len(x) for x in re.split('([A-Z]*)',line)]
                        gap=True                
                        seq=0
                        ind=0
                        for x in chunks:                                                    
                            if gap:        
                                gap=False
                            else:
                                if (seq + x >= start):
                                    s = max(start,seq+1)
                                    s = ind + s - seq
                                    e = min(seq+x,end)
                                    e = ind + e - seq
                                    line="".join([line[:s-1], MISSING_CHAR*(e-s+1),line[e:]])
                                gap=True
                                seq+=x
                                if seq >= end:
                                    break
                            ind += x
                        checkcount += 1
                    outfile.write(line+"\n")                        
            outfile.close()
            
            if (geneSanityCheckCount != checkcount):
                print "ERROR: not all sequences were found for ID: " + gene
                sys.exit(1)
            ''' Go to Next gene '''
            abePerGene = {}
            geneSanityCheckCount = 0
        gene = l[0]
        tmp = abePerGene.get(l[1],[])
        tmp.append({"start":(int(l[2]) - 1) * multiplyBy + 1, "end":int(l[3])* multiplyBy})
        abePerGene[l[1]] = tmp
        geneSanityCheckCount += 1
    
#    for file in locate("*." % (sys.argv[1]) ):
#        p = sub.Popen(['simplifyfasta.sh',file],stdout=sub.PIPE,stderr=sub.PIPE)
#        output, errors = p.communicate()
#        if errors is not None and errors != "":
#            print errors
#            sys.exit(1)
#        outfile = open("%s.cleaned" %(file),'w')
#
#        for line in output.split("\n"):
#            if line.startswith(">"):
#                seqName = line[1:]
#            else:
#                if (len(line) > filemaxlen):
#                    filemaxlen = len(line)
#                if ( len(line) > MAX_LENGTH ):
#                    print "skipping %s from %s due to length: %d" %(seqName, file, len(line))
#                    continue
#                match = re.search(pattern,line)
#                if  seqName[0:6] in N_SEQS and match is not None:
#                    print "skipping %s from %s due to long Stretch of %s at position %d" %(seqName, file, MISSING_CHAR, match.start())
#                    continue
#                outfile.write(">%s\n%s\n" %(seqName,line))         
#        outfile.close()
#        print >>sys.stderr, "%s %d" %(file,filemaxlen)