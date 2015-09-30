#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/setup.sh

export j="$WS_GLB_LIB/astral.4.7.8.jar"

if [ $# -lt 2 ]; then 
 echo "USAGE: $0 input output [any other astral parameters]"
 exit 1;
fi 

in=$1
out=$2

if [ -s $out ]; then
  echo "Ouput files exists. Refusing to rerun. "
  exit 0;
fi

java -Xmx2048M -jar $j -i $in -o $out 1>$out.astral.out 2>$out.astral.err

test "$?" != "0" && exit 1


echo ASTRAL Done. Output at: $out
