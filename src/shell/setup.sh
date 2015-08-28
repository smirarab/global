#!/bin/bash

if [ -z $WS_HOME ]; then
  echo you need to set $WS_HOME or else nothing else works.
  echo set $WS_HOME to the parent directory where the 'global' direcotry resides
  exit 1
fi

export WS_GLB_HOME=$WS_HOME/global
export WS_GLB_LIB=$WS_GLB_HOME/lib
export WS_GLB_BIN=$WS_GLB_HOME/bin
export WS_GLB_SH=$WS_GLB_HOME/src/shell
export WS_GLB_PUTIL=$WS_GLB_HOME/src/mirphyl/utils

#export PATH=$PATH:$WS_GLB_SH:$WS_GLB_PUTIL:$WS_GLB_BIN
