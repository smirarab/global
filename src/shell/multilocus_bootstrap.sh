#!/bin/sh

if [ $# -lt 3 ]; then  
  echo "USAGE: $0 [number of bootstraps] [dir] [outdir]"
  exit 1
fi

tmp=`mktemp -d BS_XXXX`

for x in $(seq 1 1 $1);
do
	echo $x;
    for y in $2/*;
    do
        head -n$x $y | tail -n1 >> $tmp/BS.$x;
    done;
done

mv $tmp $3
