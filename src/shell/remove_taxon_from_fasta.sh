#!/bin/bash


if [ $# -lt 2 ]; then
	echo "USAGE: $0 <sequence name> <input file> [-rev] [sequence name file]"
	exit 1
fi

keep=$1

if [ $keep == "-" ]; then
  keep=`cat $4| tr '\n' '|'`
fi

if [ "$3" == "-rev" ]; then
  c='/>/ {p=0} />('$keep')$/ {p=1} {if (p) {print $0};}'
else
  c='/>/ {p=1} />('$keep')$/ {p=0} {if (p) {print $0};}'
fi

awk "$c" $2
