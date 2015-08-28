Here are the description of some (maybe someday all) of the scripts shown here.
Each script would ideally give their usage (again someday!):

* [triplet.freq.sh](triplet.freq.sh): given a file with a bunch of newick trees, computes the frequencies of the three topologies for all n choose 3 quartets and outputs results to standard output. 
  * This is just a wrapper around excellent code from a [MS thesis by Jens Johansen](http://jensjohansen.com/thesis/). Thanks Jens!
  * The binaries of Jen's code is *not* included in this package. Please download that code from the link above, make it, and put it in the binaries under `$WS_HOME/bin` and name the binary file `triplets.soda2103`.
  * Note that the script can be easily adopted to do quartets instead of triplets (TODO). 
  * python > 2.6 is a requirement (but python >3.0 would probably not work). 

* [compareTrees.missingBranch](compareTrees.missingBranch): compare an estimated tree versus a reference tree, and outputs the 
  missing branch rate (FN). 
  * The output format is:

  ```[number of branches in reference] [number of branches in the reference tree not found in the estiamte tree] [fraction of branches in refrence not found in estimated]```
  
  * This is just a wrapper around a perl script by Morgan Price, and available [here](http://www.microbesonline.org/fasttree/treecmp.html). Thanks Morgan!
  * No extra steps for installation should be required, except you need to have perl installed. 

