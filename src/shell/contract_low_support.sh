#!/bin/bash

if [ $# != 2 ]; then
  echo USAGE: $0 threshold tree_file;
  exit 1
fi

case $2 in
     /*) f=$2;;
     *) f=`pwd`/$2 ;;
esac

$WS_HOME/global/src/perl/calculate_bootstrap_tree_from_bipartitions.pl -i $f -o $f.$1 -t $1
