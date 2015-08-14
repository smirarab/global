#!/bin/bash

remove_taxon_from_fasta.sh `simplifyfasta.sh $1| grep -B1 -E "^--*$"|grep ">"|sed -e "s/>//g"|paste -sd "|"` $1 > $2
