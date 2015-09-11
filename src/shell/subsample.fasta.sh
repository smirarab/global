#!/bin/bash

if [ "$#" != '3' ]; then
 echo "USAGE: $0 [file with taxon names] [input] [output]"
 exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

$DIR/remove_taxon_from_fasta.sh `sed -e "s/^/(/g" -e "s/$/)|/g" $1 |tr -d '\n'|sed -e "s/|$//g"` $2 -rev > $3
