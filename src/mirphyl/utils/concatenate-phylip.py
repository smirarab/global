import sys

genecount=None
if len(sys.argv) > 3:
	genecount=int(sys.argv[3])

subset=None
if len(sys.argv) > 2:
	subset = set()
	gc=0
	for line in open(sys.argv[2]):
		subset.add(int(line.strip()))
		gc += 1
		if genecount is not None and gc >= genecount:
			break

alg=dict()
s=0
i=0
skip=False
for line in open(sys.argv[1]):
	s = line.split()
        if not s[1].isdigit():
		if not skip:
			l = alg.get(s[0],[])
			l.append(s[1])
			alg[s[0]] = l
	else:
		i += 1
		if subset is not None and not i in subset:
			skip=True
		else:
			skip=False

l = 0
for k,vl in alg.iteritems():
	v=''.join(vl)
	if l == 0:
		l = len(v)
	if l != len(v):
		raise Exceptoin("Key %s has %d columns instead of %d" %(k,len(v),l))
	print ">"+k
	print v
