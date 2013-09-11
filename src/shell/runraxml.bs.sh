#!/bin/bash
set -x

id=$1 # This is gene ID
C=$2  # number of CPUs
H=$3  # Directory where genes are located
in=$4 # name of input alignment
rep=$5 # Number of replicates
model="GTRGAMMA" # DNA Model to use
T=`echo $model|sed -e "s/\(.*\)/\L\1/g"`
dirn=raxmlboot.$T # output raxml directory

out="" # give the  outgroup name with -o
echo Rooting at $out

cd $H/$id/

mkdir logs

mkdir -p $dirn
cd $dirn

if [ ! -s $in.phylip ] || [ "`head -n1 $in.phylip`" == "0 0" ] ; then
 $WS_HOME/global/src/shell/convert_to_phylip.sh ../$in $in.phylip
 rm $in.phylip.reduced
fi

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
      raxmlHPC-PTHREADS-SSE3-7.3.5-64bit $out -m $model -n ml -s $in.phylip -N $crep -b $RANDOM -T $C  -p $RANDOM &>$H/$id/logs/ml_std.errout.$T
   else 
      raxmlHPC-SSE3-7.3.5-64bit $out -m $model -n ml -s $in.phylip -N $crep -b $RANDOM -p $RANDOM &>$H/$id/logs/ml_std.errout.$T
   fi
  fi
fi

cat  RAxML_bootstrap.ml* > RAxML_bootstrap.all

if [ ! `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -eq $rep ]; then
 echo `pwd`>>$H/notfinishedproperly
 exit 1
else
 rm *info*final.back*
 rename "s/final/final.back/g" *final.f$rep
 #Finalize 
 raxmlHPC-SSE3-7.3.5-64bit $out -f b -m $model -n final.f$rep -z RAxML_bootstrap.all -t RAxML_bestTree.best 
 #/share/home/01721/smirarab/bin/mapsequences.py raxml/RAxML_bipartitions.ml namemap ml.mapped -rev &>logs/map
 cd ..
 if [ -s $H/$id/$dirn/RAxML_bipartitions.final.f$rep ]; then
  echo "Done">.done.raxml.$T.$rep.2
  cd $dirn
  cat  RAxML_bootstrap.ml* > .tmp
  tar cfj boot.$rep.run.logs.tar.bz --remove-files RAxML_bootstrap.ml* RAxML_*back* RAxML_info.ml.*
  mv .tmp RAxML_bootstrap.ml.$rep
 else
  echo Sorry, Failed!
 fi
fi
