import random
import sys
from collections import Counter
import os
import os.path

gene_count = len(sys.argv) - 6

reps = int(sys.argv[1])
seed = int(sys.argv[2])
bootstrap_file_name = sys.argv[3]
alignment_file = sys.argv[4]
genesampling = True if sys.argv[5] == "genesite" else False

random.seed(seed)



condor='''+Group = "GRAD"
+Project = "COMPUTATIONAL_BIOLOGY"
+ProjectDescription = "Binning"

Universe = vanilla

Requirements = Arch == "X86_64"

executable = /projects/sate7/smirarab/workspace/global/src/shell/runraxml.bs.sh

Log = logs/mlbs.log

getEnv=True

'''

all_samples=dict()
for rep in xrange(0,reps):
    if genesampling:
        gene_samples = Counter((random.randint(0,gene_count-1) for i in xrange(0,gene_count)))     
    else:
        gene_samples = dict(zip(range(0,gene_count),[1]*gene_count))
    for i,g in enumerate(sys.argv[6:]):
        #base_name = os.path.basename(g)
        #dir_name = os.path.abspath(os.path.dirname(g))
        #print i, all_samples.get(i,[])
        all_samples[i] = all_samples.get(i,[]) + [gene_samples.get(i,0)]

for i,g in enumerate(sys.argv[6:]):
    a = reduce(lambda x,y: x+y,([j+1] * x for j,x in enumerate(all_samples[i])))
    print os.path.basename(g), ",".join(str(x) for x in a) #,sum(all_samples[i])
    trees = open(os.path.join(g,bootstrap_file_name)).readlines()
    missing = sum(all_samples[i])  - len(trees)
    if missing > 0:
        print >>sys.stderr, "Not enough replicates present"
        sys.exit(1)
        condor = condor + '''
 Arguments = %s 1 %s %s %d - cont2
 Error=logs/mlbs.%s.err
 Output=logs/mlbs.%s.ut
 Queue
''' %(base_name,dir_name,alignment_file.replace("@",base_name),
                missing,base_name,base_name)

#print condor
