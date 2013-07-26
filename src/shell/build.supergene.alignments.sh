#!/bin/bash

bp=$1
support=$2
rep=$3
BINHOME="pairwise/scaledup2.10reps.$[bp]bp.$support/R$rep"
ALIGNHOME="NewSimulatedSequencesFromIntrons4000Scaled2Up_$[bp]b/R$rep"
OUTDIR="scaledup2.10reps.supergenes-$[bp]bp-$support/R$rep"
OUTFILE="supergene"

bp=$1
support=$2
rep=$3
BINHOME="pairwise/R$rep"
ALIGNHOME="R$rep"
OUTDIR="supergenes-100genes-$support/R$rep"
OUTFILE="supergene"

EXT=fasta

mkdir -p $OUTDIR


for y in `wc -l $BINHOME/bin*txt|grep -v total|awk '{if ($1==1)print $2}'`; do 
  x=`echo $y|sed -e "s/.*bin/bin/g"`
  g=`cat $y`
  mkdir $OUTDIR/$x
  #ln -s `pwd`/$ALIGNHOME/$g/raxmlboot.gtrgamma/ $OUTDIR/$x  # this is for avian simulated
  ln -s `pwd`/$ALIGNHOME/$g/ $OUTDIR/$x
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
