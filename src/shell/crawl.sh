#!/bin/sh
echo DATASET REPLICA FACTORS STAT VAL
find -name *.stat|xargs grep ' '|sed -e 's/\/\([^\/]*\).stat:/ \U\1_/g' -e 's/\// /g' -e 's/^\. //g'
