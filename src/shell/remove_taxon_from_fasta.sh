#!/bin/sh
if [ $# -ne 2 ]; then
	echo "USAGE: $0 <sequence name> <input file>"
	exit 1
fi
c='/>/ {p=1} />'$1'$/ {p=0} {if (p) {print $0};}'
awk "$c" $2
