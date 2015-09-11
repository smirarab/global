This is a hodgepodge of various scripts that I use to get through my (phylogenetic) day. 

These scripts are poorly documented, poorly tested, poorly developed, poorly connected, and poorly designed. 

You probably will have lots of trouble using many of them as they might have "outside" dependencies. 

I am hoping to improve this at some point to be better documented, better tested, more organized, and just better. 

Oh, and no, just because this code has all these poor qualities, it doesn't mean it is not useful (that triple negative sentence is poorly phrased too).


### Installation 

Installing this package is going to be easy, but getting it to actually work, no so much. 

1. Set environmental variable `WS_HOME` to the directory under which this "global" repository lives
2. `cd src; python setup.py develop`; If you don't have root, you might need `python setup.py develop --user`;

On MAC, you need to install the standard coreutils and then you need GNU command line tools for many of these scripts to work. 
I found [this](https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/) link useful. Even then, some of these tools are bash-heavy and I have only tested many of them on Ubuntu. Even with coreutils and all the rest, some of these tend to not work. 

If some scripts weren't working, the following tips might help. 

1. Don't panick
2. Add `$WS_HOME/global/src/mirphyl/utils/` and `$WS_HOME/global/src/shell/` to your `$PATH`
3. Look at `src/shell/setup.sh` and consider running it manually (this should be run by the scripts internally)
4. Be ready to change hard-coded paths (argh!)

### Dependencies:
1. An often dependency is Dendropy, but it should be Dendropy 3.X and not 4.X (I will do something about this). 
2. Java (for some tools)
3. Perl (for some tools)
4. [newicktools](http://cegg.unige.ch/newick_utils) (rarely)
5. triplet or quartet code from [this thesis](http://jensjohansen.com/thesis/)

