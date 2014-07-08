import random
import sys
from collections import Counter
import os
import os.path

usage="%s reps seed bootstrap_file_name [genesite/site] dir1 dir2 dir3 ..." %(sys.argv[0])
print >>sys.stderr, usage
 
gene_count = len(sys.argv) - 5

reps = int(sys.argv[1])
seed = int(sys.argv[2])
bootstrap_file_name = sys.argv[3]
genesampling = True if sys.argv[4] == "genesite" else False

random.seed(seed)


all_samples=dict()
for rep in xrange(0,reps):
    if genesampling:
        gene_samples = Counter((random.randint(0,gene_count-1) for i in xrange(0,gene_count)))     
    else:
        gene_samples = dict(zip(range(0,gene_count),[1]*gene_count))
    for i,g in enumerate(sys.argv[6:]):
        all_samples[i] = all_samples.get(i,[]) + [gene_samples.get(i,0)]

for i,g in enumerate(sys.argv[5:]):
    a = reduce(lambda x,y: x+y,([j+1] * x for j,x in enumerate(all_samples[i])))
    print os.path.basename(g), ",".join(str(x) for x in a) #,sum(all_samples[i])
    trees = open(os.path.join(g,bootstrap_file_name)).readlines()
    missing = sum(all_samples[i])  - len(trees)
    if missing > 0:
        print >>sys.stderr, "Not enough replicates present: %s" %os.path.join(g,bootstrap_file_name)
        sys.exit(1)
