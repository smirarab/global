#!/bin/bash

tmp=`mktemp`

ref=$1
shift

while (( "$#" )); do
   
  #cat $ref | paste - $1 |awk 'BEGIN{s=0;l=0}{l+=1;s+=sqrt(($2-$6)^2+($3-$7)^2+($4-$8)^2)}END{print s/l}'
  cat $ref | paste - $1 |awk '
   BEGIN{s=0;l=0}
   {  
      if ($1 != $5) {print "Error on",$1, $5; exit 1;}
      y=($2+$3+$4);
      p1 = $2/y; p2 = $3/y; p3 = $4/y;
      x=($6+$7+$8);
      if ($6 != 0) { q1 = $6/x} else {q1 = 0.0000000000001}
      if ($7 != 0) { q2 = $7/x} else {q2 = 0.0000000000001}
      if ($8 != 0) { q3 = $8/x} else {q3 = 0.0000000000001}
      d = 0
      if (p1 != 0) d+= p1*log(p1/q1) 
      if (p2 != 0) d+= p2*log(p2/q2) 
      if (p3 != 0) d+= p3*log(p3/q3) 
      l+=1;
      s+=d;
      print $1,d;
   }
   END{print "'$1'",s/l > "/dev/stderr"}'

  shift

done
