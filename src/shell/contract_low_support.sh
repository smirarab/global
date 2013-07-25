#!/bin/bash

$WS_HOME/global/src/perl/calculate_bootstrap_tree_from_bipartitions.pl -i `pwd`/$1 -o `pwd`/$1.$2 -t $2
