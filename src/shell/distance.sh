#!/bin/bash

test $# == 2  || { echo USAGE: input_fasta oupt_stat_file_name; exit 1; }

output=$2

java -cp $WS_HOME/global/src/java/distance AlignmentStatistics $*

sed -i -e 's/ |//g' $output
