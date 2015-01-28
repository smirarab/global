#!/bin/sh

tmp=`mktemp`
cat $1| xargs -I@ sh -c 'echo -n "@" >'$tmp'; /projects/sate7/tools/bin/triplets.soda2103 fancy printTriplets '$tmp';'|python $WS_HOME/global/src/mirphyl/utils/summarize.triplets.py
