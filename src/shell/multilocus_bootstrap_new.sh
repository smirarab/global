#!/bin/bash

if [ $# -lt 4 ]; then  
  echo "USAGE: $0 [number of bootstraps] [dir] [FILENAME] [outdir] [outname] [sampling]"
  exit 1
fi

outname="$5"
#echo $outname
outdir=$4
sampling=$6

mkdir $outdir


for x in $(seq 1 1 $1); do >$outdir/$outname.$x; done

assign=`python ~/workspace/global/src/mirphyl/utils/mlbs-gene-sampling.py $1 12 $3 @.fasta $sampling $2/*`
test $? == 0 || exit 1
echo "${assign}"| while read b c; do
   n=0
   yd=$2/$b
   y=$yd/$3
   if [ -f $y ]; then
      IFS=',' read -ra REPS <<< "$c"
      le=${#REPS[@]}
      echo $b, $le
      while read line; do
        ind=${REPS[$n]}
        t=`echo $line| sed -e "s/)[0-9]*/)/g"`
        test "$t" == "" && exit 1; #echo ERROR: tree is empty 
        echo $t >> $outdir/$outname.$ind
        n=$((n + 1))
        if [ $n == $le ]; then break; fi
      done < $y      
      test $n == $le || exit 1;
   fi
done 

#echo "`wc -l $outdir/$outname.$x|tail -n1`" "$(($1 * f)) total"
#test "`wc -l $outdir/$outname.$x|tail -n1`" == "$(($1 * f)) total" || exit 1
echo "Done!"
