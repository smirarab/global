#!/usr/bin/env python
'''
Created on Dec 21, 2016

@author: smirarab
'''
import dendropy
import sys
import os
import copy
import bisect

sys.setrecursionlimit(50000)

def is_number(s):
	try:
		float(s)
		return True
	except ValueError:
		return False
	
if __name__ == '__main__':

	if (len(sys.argv) < 2):
		print("USAGE: %s tree_file [threshold 1] [threshold 2]" %sys.argv[0])
		sys.exit(1)

	treeName = sys.argv[1]			
	
	trees = dendropy.TreeList.get_from_path(treeName, 'newick')

	thresholds = {}
	for tsh in sys.argv[2:]:
		thresholds[float(tsh)] = []
	st = sorted(thresholds.keys())

	if len(trees) > 1:
		sys.stderr.write("  Warning: only the first tree in your file will be used. ")

	tree=trees[0]
	tree.calc_node_ages(ultrametricity_precision=False, is_force_max_age = True)
	stack = []
	for n in tree.postorder_node_iter():
		n.label = n.age
		if not n.parent_node:
			break
		if n.is_leaf():
			name = n.taxon.label
		else:
			name = []
			for c in range(0,n.num_child_nodes()):
				name.append(stack.pop())
			name = ','.join(name)
		stack.append(name)
		for tsh in st[bisect.bisect_right(st,n.age):bisect.bisect_right(st,n.parent_node.age)]:
			thresholds[tsh].append(name)

	trees.write(path="%s-with-age.tre" %treeName,schema='newick', suppress_internal_node_labels=False)

	print (thresholds)
