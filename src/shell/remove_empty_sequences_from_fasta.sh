#!/bin/bash

test $# == 1 || { echo USAGE: $0 fasta_file; exit 1; }

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

$DIR/remove_taxon_from_fasta.sh `$DIR/simplifyfasta.sh $1| grep -B1 -E "^--*$"|grep ">"|sed -e "s/>//g"|paste -sd "|"` $1
