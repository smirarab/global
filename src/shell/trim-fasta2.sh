#!/bin/bash

test $# == 3 || { echo USAGE: $0 start end fasta_file; exit 1; }

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

s=$1
e=$2
e=$(( e - s  ))

shift
shift

$DIR/simplifyfasta.sh $1 |awk '/^ *[^>]/{print substr($1,'$s','$e')} /^ *[>]/{print $1}'
