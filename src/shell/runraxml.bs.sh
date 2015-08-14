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

part=""
pp="unpart"
[ $# -gt 5 ] && [ $6 != "-" ] && part="-M -q $6"
[ $# -gt 5 ] && [ $6 != "-" ] && pp="part"
dirn=$dirn.$pp

name=ml
[ $# == 7 ] && [ $7 != "-" ] && name="$7"
all=all
[ $# == 7 ] && [ $7 != "-" ] && all="all-$name"
final=final
[ $# == 7 ] && [ $7 != "-" ] && final="final-$name"

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
[ $# == 6 ] && ln -s ../$6 .

#Figure out if bootstrapping has already finished
donebs=`grep "Overall Time" RAxML_info.$name`
#Bootstrap if not done yet
if [ "$donebs" == "" ]; then
  crep=$rep
  if [ `ls RAxML_bootstrap.$name*|wc -l` -ne 0 ]; then 
   l=`cat RAxML_bootstrap.$name*|wc -l|sed -e "s/ .*//g"`
   crep=`expr $rep - $l`
  fi
  mv RAxML_bootstrap.$name RAxML_bootstrap.$name.$l
  mv RAxML_info.$name RAxML_info.$name.$l
  if [ $crep -gt 0 ]; then
   if [ $C -gt 1 ]; then
      raxmlHPC-8.0.19-PTHREADS-SSE3-modified $out -m $model -n $name -s $in.phylip -N $crep -b $RANDOM -T $C  -p $RANDOM $part &>$H/$id/logs/${name}_std.errout.$T
   else 
      raxmlHPC-8.0.19-SSE3-modified $out -m $model -n $name -s $in.phylip -N $crep -b $RANDOM -p $RANDOM $part &>$H/$id/logs/${name}_std.errout.$T
   fi
  fi
fi

cat  RAxML_bootstrap.$name* > RAxML_bootstrap.$all

if [ ! `wc -l RAxML_bootstrap.$all|sed -e "s/ .*//g"` -eq $rep ]; then
 #echo `pwd`>>$H/notfinishedproperly
 exit 1
else
 rm *info*$final.back*
 rename "s/$final/$final.back/g" *$final.f$rep
 #Finalize 
 raxmlHPC-8.0.19-SSE3-modified $out -f b -m $model -n $final.f$rep -z RAxML_bootstrap.$all -t RAxML_bestTree.best 
 #/share/home/01721/smirarab/bin/mapsequences.py raxml/RAxML_bipartitions.ml namemap ml.mapped -rev &>logs/map
 cd ..
 if [ -s $H/$id/$dirn/RAxML_bipartitions.$final.f$rep ]; then
  echo "Done">.done.raxml.$T.$rep.$pp.2
  cd $dirn
  cat  RAxML_bootstrap.$name* > .tmp
  tar cfj boot.$rep.run.logs.tar.bz --remove-files RAxML_bootstrap.$name* RAxML_*back* RAxML_info.$name.*
  mv .tmp RAxML_bootstrap.$name.$rep
 else
  echo Sorry, Failed!
 fi
fi
