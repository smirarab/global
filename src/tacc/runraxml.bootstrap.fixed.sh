#!/bin/bash
set -x

H=/work/01721/smirarab/jarvis/introns/afterfiltering/2500orthologs
T=$2
S=raxml
C=$3
id=$1
in=$T
model="GTRCAT"
rep=200
boot="-b 1000"

module load jdk64 
module swap pgi gcc
module load python

cd $H/$id/

mkdir $H/$id/logs

mkdir raxmlboot.$T
cd raxmlboot.$T

[ ! "$4" == "-res" ] || ( rm -r  logs/ml_std.errout.$T raxmlboot.$T )

if [ ! -s $in.phylip ] || [ "`head -n1 $in.phylip`" == "0 0" ] ; then
 $HOME/workspace/global/src/shell/convert_to_phylip.sh ../$in > $in.phylip
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


#Figure out if bootstrapping has already finished
donebs=`grep "Overall Time" RAxML_info.ml`
#Bootstrap if not done yet
if [ "$donebs" == "" ]; then
  crep=$rep
  if [ `ls RAxML_bootstrap.ml*|wc -l` -ne 0 ]; then 
   l=`cat RAxML_bootstrap.ml*|wc -l|sed -e "s/ .*//g"`
   crep=`expr $rep - $l`
  fi
  mv RAxML_bootstrap.ml RAxML_bootstrap.ml.$l
  mv RAxML_info.ml RAxML_info.ml.$l
  if [ $crep -gt 0 ]; then
   if [ $C -gt 1 ]; then
      $HOME/bin/raxmlHPC-PTHREADS-SSE3-git-July6 $out -m $model -n ml -s $in.phylip -N $crep -b $RANDOM -T $C  -p $RANDOM &>$H/$id/logs/ml_std.errout.$T
   else 
      $HOME/bin/raxmlHPC-SSE3-git-July6 $out -m $model -n ml -s $in.phylip -N $crep -b $RANDOM -p $RANDOM &>$H/$id/logs/ml_std.errout.$T
   fi
  fi
fi

cat  RAxML_bootstrap.ml* > RAxML_bootstrap.all

if [ ! `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -eq $rep ]; then
 echo `pwd`>>$H/notfinishedproperly
 exit 1
else
 rename "final" "final.back" *final.$rep
 #Finalize 
 $HOME/bin/raxmlHPC-SSE3-git-July6-bin $out -f b -m $model -n final.$rep -z RAxML_bootstrap.all -t RAxML_bestTree.best 
 #/share/home/01721/smirarab/bin/mapsequences.py raxml/RAxML_bipartitions.ml namemap ml.mapped -rev &>logs/map
 cd ..
 if [ -s $H/$id/raxmlboot.$T/RAxML_bipartitions.final.$rep ]; then
  echo "Done">.done.$S.$T.$rep
  cd raxmlboot.$T
  cat  RAxML_bootstrap.ml* > .tmp
  tar cfj boot.$rep.run.logs.tar.bz --remove-files RAxML_bootstrap.ml* RAxML_*back* RAxML_info*
  mv .tmp RAxML_bootstrap.ml.$rep
 else
  echo Sorry, Failed!
 fi
fi
