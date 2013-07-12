#!/bin/sh

tmp=`mktemp`

# simplifyfasta.sh
sed -e "s/>\(.*\)/@>\1@/g" $1|tr -d "\n"|tr "@" "\n"|tail -n+2> $tmp

#find length and count
len=`cat $tmp|grep -v ">"| wc -L`
count=`grep ">" $tmp|wc -l`

echo "$count $len"
cat $tmp|tr "\n" ";"|sed -e "s/;>/\n/g" -e "s/;/ /g" -e "s/>//g"
