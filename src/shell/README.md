Here are the description of some (maybe someday all) of the scripts shown here.
Each script would ideally give their usage (again someday!):

On MAC, you need to install the standard coreutils and then you need GNU command line tools for many of these. 
I found [this](https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/) link useful. 

* [setup.sh](setup.sh): this file is internally called by other scripts to set up some env variables they use. 
  For it to work, you need to have set `$WS_HOME` as explained [here](../../README).

* [triplet.freq.sh](triplet.freq.sh): given a file with a bunch of newick trees, computes the frequencies of the three topologies for all n choose 3 quartets and outputs results to standard output. 
  * This is just a wrapper around excellent code from a [MS thesis by Jens Johansen](http://jensjohansen.com/thesis/). Thanks Jens!
  * The binaries of Jen's code is *not* included in this package. Please download that code from the link above, make it, and put it in the binaries under `$WS_HOME/bin` and name the binary file `triplets.soda2103`.
  * Note that the script can be easily adopted to do quartets instead of triplets (TODO). 
  * python > 2.6 is a requirement (but python >3.0 would probably not work). 

* [compareTrees.missingBranch](compareTrees.missingBranch): compare an estimated tree versus a reference tree, and outputs the 
  missing branch rate (FN). 
  * The output format is:

    `[number of branches in reference] [number of branches in the reference tree not found in the estiamte tree] [fraction of branches in refrence not found in estimated]`
 
  * This is just a wrapper around a perl script by Morgan Price, and available [here](http://www.microbesonline.org/fasttree/treecmp.html). Thanks Morgan!
  * No extra steps for installation should be required, except you need to have perl installed. 
  * The reference tree can be multiple lines; in that case, the comparison is between the reference tree (only first line) and all estimated trees. 
  * use `-simplify` if the two trees are not on the same taxa but you want to force them to be
  * If you get a criptic error message, run [compareTrees](compareTrees) instead, and you should get more useful error messages

* [compareTrees](compareTrees): similar to [compareTrees.missingBranch](compareTrees.missingBranch), but instead of printing just the FN, it prints an extensive branch by branch comparison of the two trees. 
  Refer to Price's [website](http://www.microbesonline.org/fasttree/treecmp.html) for more info. 
  * This is useful for branch length and bootstrap support comparison. 

* [simplifyfasta.sh](simplifyfasta.sh): a one-liner that standardizes fasta alignment files so that each sequence is only one line. Simple and sweet with no dependencies. 

* [annotate-with-genes.sh](annotate-with-genes.sh): reads a bunch of source trees and a destination tree, and annotates the branches of the destination tree 
  with the number (or frequency) of source trees that have that branch with high support
