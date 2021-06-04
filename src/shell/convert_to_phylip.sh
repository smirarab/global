#!/bin/sh

#:test $# == 2 || $( echo USAGE: input_fasta output_phylip_file_name; exit 1; )

tmp=`mktemp`

sed -e "s/>\(.*\)/@>\1@/g" $1|tr -d "\n"|tr "@" "\n"|tail -n+2> $tmp

#find length and count
len=`cat $tmp|grep -v ">"| wc -L`
count=`grep ">" $tmp|wc -l`

echo $count $len >$2
cat $tmp|tr "\n" ";"|sed -e "s/;>/\n/g" -e "s/;/ /g" -e "s/>//g" >>$2

rm $tmp
