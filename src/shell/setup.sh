#!/bin/bash

if [ -z $WS_HOME ]; then
  echo you need to set $WS_HOME or else nothing else works.
  echo set $WS_HOME to the parent directory where the 'global' direcotry resides
  exit 1
fi

export MHOME=$WS_HOME/global
export MLIB=$MHOME/lib
export MSH=$MHOME/src/shell
export MPUTIL=$MHOME/src/mirphyl/utils

$PATH=$PATH:$MSH:$MPUTIL
