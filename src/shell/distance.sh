#!/bin/sh
java -cp $WS_HOME/global/src/java/distance AlignmentStatistics $*
output=`echo $*|awk '{print $2}'`
sed -i -e 's/ |//g' $output
