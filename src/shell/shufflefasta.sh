#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/setup.sh

$WS_GLB_SH/simplifyfasta.sh $1|sed 'N;s/\n/@/' |shuf|tr "@" "\n"
