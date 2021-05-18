import sys

frq=dict()
for line in sys.stdin:
    trip=line.replace("|","").split()
    k = "/".join(sorted(trip))
    v = frq.get(k, dict (zip(trip,[0]*3)))
    v[trip[0]] += 1
    frq[k] = v

for k in sorted(frq.keys()):
    print k,
    tf = frq[k]
    for t in sorted(tf.keys()):
        print tf[t],
    print
