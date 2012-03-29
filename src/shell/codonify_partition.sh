#!/bin/sh
cat $1|sed -e "s/-/ /g"|awk '{print $1 " codon1gene" NR " = " $3 "-" $4 "\\3\n" $1 " codon2gene" NR " = " $3+1 "-" $4 "\\3\n" $1 " codon3gene" NR " = " $3+2 "-" $4 "\\3"}'
