#!/bin/bash

if [ $# != 2 ]; then
  echo USAGE: $0 threshold tree_file;
  exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

case $2 in
     /*) f=$2;;
     *) f=`pwd`/$2 ;;
esac

perl $WS_GLB_PERL/calculate_bootstrap_tree_from_bipartitions.pl -i $f -o $f.$1 -t $1
