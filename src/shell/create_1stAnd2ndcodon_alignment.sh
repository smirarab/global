#!/bin/bash
#set -x
set -e

export PERL5LIB="$PERL5LIB:$HOME/workspace/global/src/perl"

if [ ! $# == 3 ]; then  
  echo USAGE: $0 alignment_file output_file output_partition_file;
  exit 1;
fi

$HOME/workspace/global/src/shell/simplifyfasta.sh $1 >$1.simp

python $HOME/workspace/global/src/mirphyl/utils/extract-codon.py $1.simp codon1st  1
python $HOME/workspace/global/src/mirphyl/utils/extract-codon.py $1.simp codon2nd  2

echo "codon1st
codon2nd" > .codon_files

perl $HOME/workspace/global/src/perl/concatenate_alignments.pl -i .codon_files -o $2 -p $3

rm codon1st codon2nd .codon_files $1.simp
