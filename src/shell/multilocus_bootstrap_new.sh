#!/bin/bash

set -u
set -e
set -o pipefail

if [ $# -lt 4 ]; then  
  echo "USAGE: $0 [number of bootstraps] [dir] [FILENAME] [outdir] [outname] [sampling] [weightfile]"
  exit 1
fi

d=$2
outdir=$4
outname="$5"
sampling=$6
weightfile=$7

mkdir -p $outdir


for x in $(seq 1 1 $1); do >$outdir/$outname.$x; done

assign=`python $WS_HOME/global/src/mirphyl/utils/mlbs-gene-sampling.py $1 12 $3 $sampling $d/*`
test $? == 0 || exit 1
while read b c; do
   n=0
   yd=$d/$b
   y=$yd/$3
   if [ -f $y ]; then
      IFS=',' read -ra REPS <<< "$c"
      le=${#REPS[@]}
      if [ $weightfile == "-" ]; then
         w=1
      else
         w=`cat $yd/$weightfile|wc -l`
      fi
      echo $b, $le, $w   
      while read line; do
        ind=${REPS[$n]}
        t=`echo $line| sed -e "s/)[0-9.e-]*/)/g"`
        test "$t" == "" && exit 1; #echo ERROR: tree is empty
        for x in $(seq 1 1 $w); do echo $t >> $outdir/$outname.$ind; done
        n=$((n + 1))
        if [ $n == $le ]; then break; fi
      done < $y      
      test $n == $le || exit 1;
   fi
done < <(echo "${assign}")

#echo "`wc -l $outdir/$outname.$x|tail -n1`" "$(($1 * f)) total"
#test "`wc -l $outdir/$outname.$x|tail -n1`" == "$(($1 * f)) total" || exit 1

echo "Done!"
