#!/bin/bash
if [ $# -lt 2 ]; then
	echo "USAGE: $0 <sequence name> <input file> [-rev]"
	exit 1
fi
if [ "$3" == "-rev" ]; then
  c='/>/ {p=0} />'$1'$/ {p=1} {if (p) {print $0};}'
else
  c='/>/ {p=1} />'$1'$/ {p=0} {if (p) {print $0};}'
fi
awk "$c" $2
