#!/usr/bin/env python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import re
from types import ListType


def get_present_taxa(tree, labels):
    return [x.taxon for x in [tree.find_node_with_taxon_label(label) for label in labels]
            if x is not None]

class Mono(object):
    
    def __init__(self,taxa):
        self.allclades = dict()
        self.clades = dict()
        self.clade_comps = dict()
        self.alltaxa = taxa
        self.letters = dict()
 
    def print_result(self, treeName, keyword, support, lst):
        ln = "_".join([str(l) for l in lst]) if type(lst) == ListType else lst
        letter = self.letters[ln]
        name="%s (%s)" %(ln,letter) if letter is not None and letter!="" else ln
        print "%s\t%s\t%s\t%s" % (treeName, keyword, support, name)
    
    def is_mono(self,tree, clade):
        mrca = tree.mrca(taxa=clade)
        for x in mrca.leaf_nodes():
            if x.taxon not in clade:
                return False, mrca
        return True, mrca

    def can_mono(self, tree, clade):
        mrca = tree.mrca(taxa=clade)
        for child in mrca.child_nodes():
            childLeaves = [x.taxon for x in child.leaf_iter()]
            intersect = [(x in clade) for x in childLeaves]
            # If a child of the mrca has both True and False (i.e. taxa of interest 
            # and others), it cannot be made monophyletic
            if (True in intersect) and (False in intersect):
                return False, mrca
            # If a child is all False (not taxa of interest), it is irrelevant.
            # If a child is all True (taxa of interst), it does not preclude monophyletic
        return True, mrca
                
    def check_mono(self,tree, treeName, clade, name, complete):
        #print complete
        m, mrca = self.is_mono(tree, clade)
            #print m
        if m:
            if complete:
                self.print_result(treeName, "IS_MONO", mrca.label, name)
            else:
                self.print_result(treeName, "IS_MONO_INCOMPLETE", mrca.label, name)
            return
        c, mrca = self.can_mono(tree, clade)
        if c:        
            if complete:
                self.print_result(treeName, "CAN_MONO", mrca.label, name)
            else:
                self.print_result(treeName, "CAN_MONO_INCOMPLETE", mrca.label, name)
            return

        self.print_result(treeName, "NOT_MONO", mrca.label, name)

    def analyze_clade(self,name, clade, comps, tree, treeName):
        taxa = get_present_taxa(tree, clade)
        taxas = set(t.label for t in taxa)
        if comps:
            for comp in comps:
                if not set(self.allclades[comp]) & taxas:
                    self.print_result(treeName, "COMP_MISSING", None, name)
                    return
        #print len(taxa), len(clade)
        if len(taxa) < 2:
            self.print_result(treeName, "NO_CLADE", None, name)
        else:
            self.check_mono (tree, treeName, taxa, name, len(taxa) == len(clade))

    def analyze(self, tree, treeName):
        for k, v in self.clades.items():
            self.analyze_clade(k, v, self.clade_comps[k], tree, treeName)

    def read_clades(self,filename):
        for line in open(filename):
            r = line.split('\t')
            if r[0] == 'Clade Name':
                continue
            clade=set()
            sign="+"
            for x in re.split("([+|-])",r[1]):
                try:
                    if x in ["+","-"]:
                        sign = x
                    else:
                        x = x.strip("\"")
                        new = set(self.allclades[x] if x not in self.alltaxa else [x])
                        if sign == "+":
                            clade.update(new)
                        else:
                            clade.difference_update(new)
                except KeyError as e:
                    print "In %s, %s is not defined before" %(r[0],e.args[0])
                    sys.exit(1)
            clade = list(clade)
            components=r[4].strip().split("+") if r[4] != "" else []
            name = r[0]
            self.letters[name] = r[3]
            self.allclades[name] = clade
            if r[2] != "None":
                self.clades[name] = clade
                self.clade_comps[name] = components

if __name__ == '__main__':
    
    taxa = set(x.split('\t')[0].strip() for x in open("names.csv").readlines())
    mono = Mono(taxa)
    mono.read_clades("clade-defs.txt")
    
    #print [(k,len(v)) for k,v in clades.items()]
    for fileName in sys.argv[1:]:
        
        trees = dendropy.TreeList.get_from_path(fileName, 'newick', rooted=True)
        namemismatch = set(t.label for t in trees.taxon_set) - taxa
        if namemismatch:
            print >> sys.stderr, "The following taxa in the tree are not found in the names file:\n %s" %str(namemismatch)
            continue
        
        for i, tree in enumerate(trees):
            treeName = "%s_%s" % (fileName.replace("_"," "), i)

            mono.analyze(tree, treeName)


#keys = clades.keys()
#keys.sort()
#print "\n".join(["%s: %s" %(x,str(clades[x])) for x in keys])
