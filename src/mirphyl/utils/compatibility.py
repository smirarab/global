#!/bin/python3

import dendropy
import sys

t=dendropy.TreeList.get(path=sys.argv[1], schema="newick")

x=dendropy.Tree()

print(str(x.from_bipartition_encoding([y  for i in t for y in i.encode_bipartitions()],t.taxon_namespace))+";")
