#!/bin/bash
set -x
module load jdk64

'Usage: runsate.sh ID INPUT_LABEL OUT_LABEL CPU MEM [-res]'

H=$WORK/$PROJECT/$DATASET/$RUN/$GENES_DIR
T=$2 # A type name, appears in output names
S=$3 # A label, appears in output names
C=$4 # cpu usage
M=$5 # max mem
label=$T.$S
input=$H/$1/input.fasta.$T
config=sate-config-$label
name=sate.$label.aligned
mafftout=mafft.$label.aligned
outdirname=sateout.$label
checkpoint=checkpoint.dump.$label
fixinput=False

cd $H/$1/
mkdir logs

if [ "$6" == "-res" ]; then
        rm -r tmp/$name $checkpoint ${outdirname}* logs/alg_std.*.$label .done.$label $mafftout
fi

if [ "$fixinput" == "True" ]; then
   # Remove empty sequences
   grep -n -B1 -E "^$" $input |grep ">"|sed -e "s/-.*/d/g" -e"s/^/-e /g"|tr "\n" " "|xargs -I@ sh -c "sed -i @ $input"
fi

# Get initial MAFFT alignment, Done separately for more flexibility
if [ ! -s $mafftout ]; then
        if [ ! -f .lnsci.failed ]; then
   	  $HOME/bin/mafft --localpair --maxiterate 1000 --ep 0.123 --thread $C $input 1> $mafftout 2>logs/MAFFT_log.$label
        fi
        echo Switching to default MAFFT >> logs/MAFFT_log.$label
        # In case of failure, use default MAFFT 
        [ -s $mafftout ] || ( touch .lnsci.failed )
        if [ -f .lnsci.failed ]; then
	  $HOME/bin/mafft --memsave --auto --ep 0.123 $input 1> $mafftout 2>>logs/MAFFT_log.$label
        fi
fi

$HOME/bin/sate.2.1.0 -i $mafftout -o $H/$1/$outdirname -j $name -c $H/$1/$checkpoint $H/../$config --max-mem-mb $M --num-cpus $C 1>$H/$1/logs/alg_std.out.$label 2>$H/$1/logs/alg_std.err.$label


if [ -s $name ]; then
 echo "Done">.done.$label
 rm -r tmp/$name/
fi
