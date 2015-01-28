#!/bin/bash

tmp=`mktemp`

ref=$1
shift

while (( "$#" )); do
   
  #cat $ref | paste - $1 |awk 'BEGIN{s=0;l=0}{l+=1;s+=sqrt(($2-$6)^2+($3-$7)^2+($4-$8)^2)}END{print s/l}'
  cat $ref | paste - $1 |awk '
   BEGIN{s=0;l=0}
   {  l+=1;
      y=($2+$3+$4)
      x=($6+$7+$8);
      a=(sqrt($2/y)-sqrt($6/x))^2 + (sqrt($3/y)-sqrt($7/x))^2 + (sqrt($4/y)-sqrt($8/x))^2;
      d=sqrt(a)/sqrt(2);
      s+=d;
      print $1,d;
   }
   END{print "'$1'",s/l}'

  shift

done
