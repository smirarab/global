#!/bin/sh

test $# == 2 || { echo USAGE: input_fasta output_phylip_file_name; exit 1; }

tmp=`mktemp XXX`

sed -e "s/>\(.*\)/@>\1@/g" $1|tr -d "\n"|tr "@" "\n"|tail -n+2> $tmp

#find length and count
len=`cat $tmp|gwc -L`
count=`grep ">" $tmp|wc -l`

echo $count $len >$2
cat $tmp|tr "\n" ";"|sed -e "s/;>/@/g" -e "s/;/ /g" -e "s/>//g" | tr '@' '\n' >>$2

rm $tmp
