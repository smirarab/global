#!/bin/bash

dir=$1
f=$2
x=$3
all=$4

$WS_HOME/global/src/shell/compareTrees.compatibility $dir/$x/$f $all |paste $all.order - -d " " | sed -e "s/"$dir."/"$x" /g" -e "s/\/[^ ]* / /g"
