Here are the description of some (maybe someday all) of the scripts shown here.
Each script would ideally give their usage (again someday!):

* [triplet.freq.sh](triplet.freq.sh): given a file with a bunch of newick trees, computers the frequencies of all n choose 3 quartets. 
  This is just a wrapper around code from a [MS thesis by Jens Johansen](http://jensjohansen.com/thesis/). Thanks Jens!
  The binaries of Jen's code is *not* included. Please download, make, and put the binaries under `$WS_HOME/bin`.
  Note that the script can be easily adopted to do quartets instead of triplets. 

* [compareTrees.missingBranch](compareTrees.missingBranch): compare an estimated tree versus a reference tree, and outputs the 
  missing branch rate (FN). The output format is:
  ```[number of branches in reference] [number of branches in the reference tree not found in the estiamte tree] [fraction of branches in refrence not found in estimated]'''
  This is just a wrapper around a perl script by Morgan Price, and available [here](http://www.microbesonline.org/fasttree/treecmp.html). Thanks Morgan!


