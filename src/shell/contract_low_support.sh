#!/bin/bash


case $1 in
     /*) f=$1;;
     *) f=`pwd`/$1 ;;
esac

$WS_HOME/global/src/perl/calculate_bootstrap_tree_from_bipartitions.pl -i $f -o $f.$2 -t $2
