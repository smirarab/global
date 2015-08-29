#!/bin/bash

test $# == 2 || { echo USAGE: $0 desired_length fasta_file; exit 1; }

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

size=$1
shift

$DIR/simplifyfasta.sh $1 |awk '/^ *[^>]/{print substr($1,0,'$size')} /^ *[>]/{print $1}'
