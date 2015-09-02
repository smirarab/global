import sys
import numpy as np
import os

frq=dict()
for line in sys.stdin:
    trip=line.replace("|","").split()
    k = "/".join(sorted(trip))
    v = frq.get(k, dict (zip(trip[1:4],[0]*3)))
    v[trip[1]] += 1
    frq[k] = v
sv = os.environ['WS_GLB_RES']

sys.stdout = open(sv+'/quartetTable.txt', 'w')
for k in sorted(frq.keys()):
    print k,
    tf = frq[k]
    for t in sorted(tf.keys()):
        print tf[t],
    print
sys.stdout = sys.__stdout__

keyDict = sorted(np.unique("/".join(frq.keys()).split("/")));
mapDict = dict()
v = set([0, 1, 2, 3])
empty = 1e-8
sz = sum(frq[frq.keys()[0]].values())
for k in sorted(frq.keys()):
	d = sorted(k.split('/'))
	for i in range(1,4): 
		distKey = d[0]+' '+d[i]
		
		if distKey not in mapDict.keys() and frq[k][d[i]]>0 and frq[k][d[i]]!=sz:
			mapDict[distKey] = -np.log(float(frq[k][d[i]])/sz)
		elif distKey not in mapDict.keys() and frq[k][d[i]]<1:
			mapDict[distKey] = -np.log(empty)
		elif distKey not in mapDict.keys() and frq[k][d[i]]==sz:
			mapDict[distKey] = -np.log(float(frq[k][d[i]]-empty)/sz)
		elif frq[k][d[i]] < 1:
			mapDict[distKey] -= np.log(empty)
		elif frq[k][d[i]]==sz:
			mapDict[distKey] -= np.log(float(frq[k][d[i]]-empty)/sz)
		else:
			mapDict[distKey] -= np.log(float(frq[k][d[i]])/sz)
		s = set([0,i])
		g = sorted(list(v - s))
		distKey = d[g[0]]+ ' ' +d[g[1]]
		
		if distKey not in mapDict.keys() and frq[k][d[i]]>0 and frq[k][d[i]]!=sz:
			mapDict[distKey] = -np.log(float(frq[k][d[i]])/sz)
		elif distKey not in mapDict.keys() and frq[k][d[i]]<1:
			mapDict[distKey] = -np.log(empty)
		elif distKey not in mapDict.keys() and frq[k][d[i]]==sz:
			mapDict[distKey] = -np.log(float(frq[k][d[i]]-empty)/sz)
		elif frq[k][d[i]] < 1:
			mapDict[distKey] -= np.log(empty)
		elif frq[k][d[i]]==sz:
			mapDict[distKey] -= np.log(float(frq[k][d[i]]-empty)/sz)
		else:
			mapDict[distKey] -= np.log(float(frq[k][d[i]])/sz)
l = len(keyDict)
print l
for i in range(0,l):
	sp = keyDict[i]
	print sp,
	for j in range(0,l):
		if i==j:
			print 0,
			continue
		k = sorted([keyDict[j],keyDict[i]])
		
		print '%0.6f' % mapDict[k[0]+' '+k[1]],
	print 
	
