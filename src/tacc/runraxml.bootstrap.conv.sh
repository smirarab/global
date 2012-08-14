#!/bin/bash
set -x

H=/work/01721/smirarab/jarvis/introns/afterfiltering/2500orthologs
T=$2
S=raxml
C=$3
id=$1
in=$T
model="GTRCAT"
rep=conv
crep=50
boot="-b 1000"
max=999

module load jdk64 
module swap pgi gcc
module load python

cd $H/$id/

mkdir $H/$id/logs

mkdir raxmlboot.$T
cd raxmlboot.$T

[ ! "$4" == "-res" ] || ( rm -r  logs/ml_std.errout.$T raxmlboot.$T )

if [ ! -s $in.phylip ] || [ "`head -n1 $in.phylip`" == "0 0" ] ; then
 $HOME/workspace/global/src/convert_to_phylip.sh ../$in > $in.phylip
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

#Figure out if bootstrapping has already converged
rename "test" "test.back" *test
rm RAxML_bootstrap.all
cat  RAxML_bootstrap.ml* > RAxML_bootstrap.all
conv="has not started yet"
if [ -s RAxML_bootstrap.all ]; then 
  $HOME/bin/raxmlHPC-SSE3-git-July6 -I autoMRE -z RAxML_bootstrap.all -m GTRCAT -n test
  conv=`grep "did not converge" RAxML_info.test`
  [ $? -ne 2 ] || ( exit 1 )
fi

#Bootstrap if not done yet
while [ "$conv" != "" ] && [ `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -le $max ]; do


   l=`cat RAxML_bootstrap.ml*|wc -l|sed -e "s/ .*//g"`
  mv RAxML_bootstrap.ml RAxML_bootstrap.ml.$l
  mv RAxML_info.ml RAxML_info.ml.$l
  if [ $crep -gt 0 ]; then
   if [ $C -gt 1 ]; then
      $HOME/bin/raxmlHPC-PTHREADS-SSE3-git-July6 $out -m $model -n ml -s $in.phylip -N $crep $boot$l -T $C  -p 100$l &>$H/$id/logs/ml_std.errout.$T
   else 
      $HOME/bin/raxmlHPC-SSE3-git-July6 $out -m $model -n ml -s $in.phylip -N $crep $boot$l -p 100$l &>$H/$id/logs/ml_std.errout.$T
   fi
  fi
  #Figure out if bootstrapping has already converged
  rename "test" "test.back" *test
  cat  RAxML_bootstrap.ml* > RAxML_bootstrap.all
  $HOME/bin/raxmlHPC-SSE3-git-July6 -I autoMRE -z RAxML_bootstrap.all -m GTRCAT -n test
  conv=`grep "did not converge" RAxML_info.test`
  [ $? -ne 2 ] || ( exit 1 )
done

if [ "$conv" == "" ] || [ `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -gt $max ]; then
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
