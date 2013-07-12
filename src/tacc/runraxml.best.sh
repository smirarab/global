#!/bin/bash
set -x

H=/work/01721/smirarab/jarvis/introns/afterfiltering/2500orthologs
T=$2
S=raxml
C=$3
id=$1
in=$T
model="GTRCAT"

module load jdk64 
module swap pgi gcc
module load python

cd $H/$id/

mkdir $H/$id/logs
#l=`grep ">" $in|wc -l`

mkdir raxmlboot.$T
cd raxmlboot.$T

[ ! "$4" == "-res" ] || ( rm -r  logs/ml_std.errout.$T raxmlboot.$T )

if [ ! -s $in.phylip ] || [ "`head -n1 $in.phylip`" == "0 0" ] ; then
 $HOME/bin/readseq.sh -f12 ../$in -o $in.phylip
 rm $in.phylip.reduced
fi

# Try to find the outgroup automatically
out=""
[ "`grep HUMAN $in.phylip`" == "" ] || out="-o HUMAN"
[ "$out" != "" ] || [ "`grep ANOCA $in.phylip`" == "" ] || out="-o ANOCA"
[ "$out" != "" ] || [ "`grep CHEMY $in.phylip`" == "" ] || out="-o CHEMY"
[ "$out" != "" ] || [ "`grep ALLIG $in.phylip`" == "" ] || out="-o ALLIG"
[ "$out" != "" ] || [ "`grep STRCA $in.phylip`" == "" -o "`grep TINMA $in.phylip`" == ""  ] || out="-o STRCA,TINMA"
[ "$out" != "" ] || [ "`grep STRCA $in.phylip`" == "" ] || out="-o STRCA"
[ "$out" != "" ] || [ "`grep TINMA $in.phylip`" == "" ] || out="-o TINMA"
[ "$out" != "" ] || ( echo "noroot" >.noroot )
echo Rooting at $out

# In case this is a re-run, rename outputs from the old runs
rename "best" "best.back" *best

# Estimate the RAxML best tree
if [ $C -gt 1 ]; then
 $HOME/bin/raxmlHPC-PTHREADS-SSE3-git-July6 $out -m $model -T $C -n best -s $in.phylip -N 10 -p 10000 &>$H/$id/logs/best
else
 $HOME/bin/raxmlHPC-SSE3-git-July6 $out -m $model -n best -s $in.phylip -N 10 -p 10000 &>$H/$id/logs/best
fi

#/share/home/01721/smirarab/bin/mapsequences.py raxml/RAxML_bipartitions.ml namemap ml.mapped -rev &>logs/map

cd ..
if [ -s $H/$id/raxmlboot.$T/RAxML_bestTree.best ]; then 
  echo "Done">.done.$S.$T.1
  cd raxmlboot.$T
  tar cfj best.run.logs.tar.bz --remove-files RAxML_log* RAxML_pars* RAxML_res*
else 
  echo Sorry, Failed!
fi
