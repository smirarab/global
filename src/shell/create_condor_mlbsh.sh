#!/bin/bash

if [ $# != 9 ]; then 
 echo "USAGE: rep_count input_dir input_bootstrap_name methods outdir outgroup repetition_file input_best_name postfix_for_rooted_file"; 
 exit 1;
fi

reps=$1
dir=$2
filen=$3
methods=$4
outdir=$5
outgroup=$6
binsize=$7
bestfilen=$8
rootpostfix=$9

MPESTREP=10

WH="$WS_HOME/global"
BH="$WH/src/shell"

HEADER="+Group = \"GRAD\"
+Project = \"COMPUTATIONAL_BIOLOGY\"
+ProjectDescription = \"Binning\"

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
 Arguments = $x $outgroup $x.$rootpostfix
 Error = $outdir/logs/reroot.err
 Output = $outdir/logs/reroot.out
 Queue">>$outdir/condor/condor.reroot
done
filen=$filen.$rootpostfix

if [ "$bestfilen" != "-" ]; then
for x in $dir/*/$bestfilen; do
 echo "
 Arguments = $x $outgroup $x.$rootpostfix
 Error = $outdir/logs/reroot.err
 Output = $outdir/logs/reroot.out
 Queue">>$outdir/condor/condor.reroot
done
bestfilen=$bestfilen.$rootpostfix
fi

fi

##################################### Create replicates. Repeat if bin size files are given, otherwise (if it is -) don't repeat.
binfile=$binsize
if [ "$binsize" == "-" ]; then
 binfile=somerandomdummyname$RANDOM
fi

echo "$HEADER
executable = $BH/multilocus_bootstrap.sh

Log = $outdir/logs/rep.log

getEnv=True

 Arguments = $reps $dir $filen $binfile $outdir/Reps
 Error = $outdir/logs/rep.err
 Output = $outdir/logs/rep.out
 Queue
">$outdir/condor/condor.rep

if [ "$bestfilen" != "-" ]; then
echo "
 Arguments = 1 $dir $bestfilen $binfile $outdir/Reps Best
 Error = $outdir/logs/rep.best.err
 Output = $outdir/logs/rep.best.out
 Queue
">>$outdir/condor/condor.rep
fi

########################################## Create the condor file for each method
for method in $methods; do

mkdir $outdir/$method
opts=""
if [ "$method" == "mpest" ]; then
   head -n1 $dir/*/$ofilen|grep -v ">"|sed -e "s/[(,);]/ /g" -e "s/ /\n/g" |sort|uniq|tail -n+2|sed -e "s/^\(.*\)$/\1 1 \1/g" >$outdir/species.list
   opts="$outdir/species.list $MPESTREP"
elif [ "$method" == "mrp" ]; then
   opts=$outdir/$method
elif [ "$method" == "greedy" ]; then
   opts=0
fi
echo "$HEADER
executable = $BH/$method

Log = $outdir/logs/$method.log

getEnv=True

initialdir = $outdir/$method
">$outdir/condor/condor.$method

for x in  $(seq 1 1 $reps); do
b=BS.$x
out=BS.$x.tre
echo "
 Arguments = ../Reps/$b $opts $out
 Error = $outdir/logs/$method.$b.err
 Output = $outdir/logs/$method.$b.out
 Queue">>$outdir/condor/condor.$method

done

if [ "$bestfilen" != "-" ]; then
echo "
 Arguments = ../Reps/Best.1 $opts Best.tre
 Error = $outdir/logs/$method.best.err
 Output = $outdir/logs/$method.best.out
 Queue">>$outdir/condor/condor.$method
fi
######################################## Summarize MPEST bootstrap replicates to get one final tree
if [ "$method" == "mpest ghadimi" ]; then

echo "$HEADER
executable = $WH/src/mirphyl/utils/sumarize_mpest.py

Log = $outdir/logs/sum.$method.log

getEnv=True

 Arguments = $outdir/mpest/mpest.all_greedy.newick.with.support ` seq -s " " -f "$outdir/$method/BS.%g.tre" 1 $reps`
 Error = $outdir/logs/sum.$method.err
 Output = $outdir/logs/sum.$method.out
 Queue
">$outdir/condor/condor.sum.$method

else

echo "$HEADER
executable = $WH/src/mirphyl/utils/greedy_consensus.py

Log = $outdir/logs/sum.$method.log

getEnv=True

 Arguments = 0 $outdir/$method/$method.all_greedy.newick.with.support ` seq -s " " -f "$outdir/$method/BS.%g.tre" 1 $reps`
 Error = $outdir/logs/sum.$method.err
 Output = $outdir/logs/sum.$method.out
 Queue
">$outdir/condor/condor.sum.$method

fi
done

######################################## Create DAG file
echo "JOB  REP  condor.rep" >$outdir/condor/dagfile

if [ "$outgroup" != "-" ]; then
echo "JOB  ROOT condor.reroot
PARENT ROOT CHILD REP" >>$outdir/condor/dagfile
fi

for method in $methods; do
 echo "
JOB  ST.$method  condor.$method
JOB  SUM.$method condor.sum.$method
PARENT REP CHILD ST.$method
PARENT ST.$method CHILD SUM.$method" >>$outdir/condor/dagfile
done


