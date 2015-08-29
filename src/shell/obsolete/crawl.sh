#!/bin/sh
echo DIR DATASET REPLICA FACTORS STAT VAL
find -L $* -name '*.stat'|xargs grep ' '|sed -e 's/\/\([^\/]*\).stat:/ \U\1_/g' -e 's/\// /g' -e 's/^\. //g' -e "s/ _/ /g"
