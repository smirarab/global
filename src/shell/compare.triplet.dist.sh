#!/bin/bash

tmp=`mktemp`

ref=$1
shift

while (( "$#" )); do
   
  echo -n $1" "
  #cat $ref | paste - $1 |awk 'BEGIN{s=0;l=0}{l+=1;s+=sqrt(($2-$6)^2+($3-$7)^2+($4-$8)^2)}END{print s/l}'
  cat $ref | paste - $1 |awk '
   BEGIN{s=0;l=0}
   {  l+=1;
      y=($2+$3+$4)
      x=($8+$6+$7);
      a=(sqrt($2/x)-sqrt($6/y))^2 + (sqrt($3/x)-sqrt($7/y))^2 + (sqrt($4/x)-sqrt($8/y))^2;
      s+=sqrt(a)/sqrt(2);
   }
   END{print s/l}'

  shift

done
