#!/bin/bash

reps=$1
dir=$2
filen=$3
methods=$4
outdir=$5
outgroup=$6
binsize=$7

BH="/projects/sate7/tools/bin"
WH="/u/smirarab/workspace/global"

HEADER="+Group = \"GRAD\"
+Project = \"COMPUTATIONAL_BIOLOGY\"
+ProjectDescription = \"two phase method\"

Universe = vanilla
"

############### Prepare directory structure 

mkdir $outdir
mkdir $outdir/logs
mkdir $outdir/condor


########################### Root gene trees if outgroup is given (i.e. is not -)
ofilen=$filen

if [ "$outgroup" != "-" ]; then
echo "$HEADER
executable = $WH/src/mirphyl/utils/reroot.noerr.py

Log = $outdir/logs/reroot.log

getEnv=True
">$outdir/condor/condor.reroot
for x in $dir/*/$filen; do
 echo "
 Arguments = $x $outgroup
 Error = $outdir/logs/reroot.err
 Output = $outdir/logs/reroot.out
 Queue">>$outdir/condor/condor.reroot
done
filen=$filen.rooted
fi

##################################### Create replicates. Repeat if bin size files are given, otherwise (if it is -) don't repeat. 
if [ "$binsize" != "-" ]; then
echo "$HEADER
executable = $BH/multilocus_bootstrap.sh

Log = $outdir/logs/rep.log

getEnv=True

 Arguments = $reps $dir $filen $binsize $outdir/Reps
 Error = $outdir/logs/rep.err
 Output = $outdir/logs/rep.out
 Queue
">$outdir/condor/condor.rep

else

echo "$HEADER
executable = $BH/multilocus_bootstrap.sh

Log = $outdir/logs/norep.log

getEnv=True

 Arguments = $reps $dir $filen somerandomdummyname$RANDOM $outdir/Reps
 Error = $outdir/logs/norep.err
 Output = $outdir/logs/norep.out
 Queue
">$outdir/condor/condor.rep
fi

########################################## Create the condor file for each method
for method in $methods; do

mkdir $outdir/$method
opts=""
if [ "$method" == "mpest" ]; then
   head -n1 $dir/*/$ofilen|grep -v ">"|sed -e "s/[(,);]/ /g" -e "s/ /\n/g" |sort|uniq|tail -n+2|sed -e "s/^\(.*\)$/\1 1 \1/g" >$outdir/species.list
   opts=$outdir/species.list
fi
echo "$HEADER
executable = $BH/$method

Log = $outdir/logs/$method.log

getEnv=True

initialdir = $outdir/$method
">$outdir/condor/condor.$method

for x in  $(seq 1 1 $reps); do
b=BS.$x
echo "
 Arguments = ../Reps/$b $opts
 Error = $outdir/logs/$method.$b.err
 Output = $outdir/logs/$method.$b.out
 Queue">>$outdir/condor/condor.$method

done

######################################## Summarize MPEST bootstrap replicates to get one final tree
if [ "$method" == "mpest" ]; then
echo "$HEADER
executable = $WH/src/mirphyl/utils/sumarize_mpest.py

Log = $outdir/logs/sum.log

getEnv=True

 Arguments = $outdir/mpest/mpest.all_greedy.newich.with.support ` seq -s " " -f "$outdir/Reps/BS.%g.tre" 1 $reps`
 Error = $outdir/logs/sum.err
 Output = $outdir/logs/sum.out
 Queue
">$outdir/condor/condor.sum
fi
done

######################################## Create DAG file
echo "JOB  REP  condor.rep
JOB  ST  condor.$method
JOB  SUM condor.sum
JOB  ROOT condor.reroot
PARENT ROOT CHILD REP
PARENT REP CHILD ST
PARENT ST CHILD SUM
" >$outdir/condor/dagfile


