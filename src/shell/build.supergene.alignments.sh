#!/bin/bash

echo "USAGE: support align_home [rep]"
test $# -gt 1 || exit 1

support=$1
OUTFILE="supergene"

if [ $# == 3 ]; then
rep=$3
BINHOME="pairwise/R$rep/$support"
ALIGNHOME="$2/R$rep"
OUTDIR="supergenes-$support/R$rep"
else
BINHOME="pairwise/$support"
ALIGNHOME="$2"
OUTDIR="supergenes-$support"
fi

EXT=fasta

mkdir -p $OUTDIR


for y in `wc -l $BINHOME/bin*txt|grep -v total|awk '{if ($1==1)print $2}'`; do 
  x=`echo $y|sed -e "s/.*bin/bin/g"`
  g=`cat $y`
  mkdir $OUTDIR/$x
  ln -fs `pwd`/$ALIGNHOME/$g/raxmlboot.gtrgamma/ $OUTDIR/$x  # this is for avian simulated
  echo ln -fs `pwd`/$ALIGNHOME/$g/raxmlboot.gtrgamma/ $OUTDIR/$x  # this is for avian simulated
  #ln -s `pwd`/$ALIGNHOME/$g/ $OUTDIR/$x/
  echo "Done" > $OUTDIR/$x/.done.raxml.gtrgamma.1
  echo "Done" > $OUTDIR/$x/.done.raxml.gtrgamma.200.2
  echo $g > $OUTDIR/$x/$OUTFILE.part
done

for y in `wc -l $BINHOME/bin*txt|grep -v total|awk '{if ($1>1)print $2}'`; do 
  cat $y|xargs -I@ echo `pwd`/$ALIGNHOME/@/@.$EXT >.t;  
  x=`echo $y|sed -e "s/.*bin/bin/g"`
  mkdir $OUTDIR/$x
  $WS_HOME/global/src/perl/concatenate_alignments.pl -i `pwd`/.t -o `pwd`/$OUTDIR/$x/$OUTFILE.fasta -p `pwd`/$OUTDIR/$x/$OUTFILE.part;
  tail -n1 `pwd`/$OUTDIR/$x/$OUTFILE.part 
  # convert_to_phylip.sh `pwd`/913supergenes/$x/sate.noout.fasta 913supergenes/$x/sate.noout.phylip; 
  echo $x done; 
done
