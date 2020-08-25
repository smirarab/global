#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

test $# == 3 || { echo USAGE: dir-name gene-count rep-count; exit 1; }

x=$1 #raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa-filterbln-3.rapid
e=$2 #410; 
rep=$3 #20
out=mlbs/$x; 
best=RAxML_bipartitions.final
bs=RAxML_bootstrap.all

mkdir -p $out; 

test  `ls genes/*/$x/$bs |tee $out/genelist|wc -l` == $e || ( echo "Number of bs genes is not $e. checkout $out/genelist"; exit 1 ) || exit 1 
test  `cat genes/*/$x/$best |tee $out/Best|wc -l` == $e || ( echo "Number of best genes is not $e. checkout $out/genelist"; exit 1 ) || exit 1 


java -jar $DIR/Astral/astral.4.7.8.jar -k bootstraps_norun -i $out/Best -b $out/genelist -o $out/BS -r $rep


echo '
+Group = "GRAD"
+Project = "COMPUTATIONAL_BIOLOGY"
+ProjectDescription = "1KP"

Universe = vanilla

Requirements = Arch == "X86_64"

executable = '$DIR'/runastral.sh

Log = condor.log

getEnv=True

' |tee $out/condor

for i in Best;                    do echo Args = $i;       echo Queue; echo; done |tee -a $out/condor

for i in `seq 0 $(( $rep - 1 ))`; do echo Args = BS.$i.bs; echo Queue; echo; done |tee -a $out/condor

