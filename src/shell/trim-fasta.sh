#!/bin/bash

size=$1
shift

simplifyfasta.sh $1 |awk '/^ *[^>]/{print substr($1,0,'$size')} /^ *[>]/{print $1}'
