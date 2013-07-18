#!/bin/bash

if [ $# -lt 4 ]; then  
  echo "USAGE: $0 [number of bootstraps] [dir] [FILENAME] [count FILENAME] [outdir] [outname optinal]"
  exit 1
fi

test "$6" == "" && outname="BS" || outname="$6"
echo $outname

outdir=$5

mkdir $outdir

bins=`ls $2|sort`

for x in $(seq 1 1 $1); do
    echo $x;
    >$outdir/$outname.$x
    for b in $bins; do
        yd=$2/$b
        y=$yd/$3
        c=`test -s $yd/$4 && cat $yd/$4|wc -l || echo 1`
        #echo count is set to $c
        if [ -f $y ]; then
         t=`head -n$x $y | tail -n1`
         test "$t" != "" && seq 1 $c| xargs -I@ -n1 echo $t >> $outdir/$outname.$x;
        fi
    done;
    test `cat $outdir/$outname.$x|wc -l` != 0 || exit 1
done

echo "Done!"
