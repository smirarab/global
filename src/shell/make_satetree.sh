#!/bin/sh
find -name raxml_sate$*|xargs -I@ sh -c 'mkdir `echo @|sed -e "s/raxml_/satetree_/g"`'
find -name raxml_sate$*|xargs -I@ sh -c 'sed -e "s/raxml.RA.*.ml/ml/g" @/condor.mb>`echo @|sed -e "s/raxml_/satetree_/g" -e "s/$/\/condor.mb/g"`'
find -name raxml_sate$*|xargs -I@ sh -c 'cp @/sateout/aligned.fasta.tre `echo @|sed -e "s/raxml_/satetree_/g" -e "s/$/\/ml/g"`'
find -name raxml_sate$*|xargs -I@ sh -c 'mkdir `echo @|sed -e "s/raxml_/satetree_/g"`/logs'
find -name raxml_sate$*|xargs -I@ sh -c 'cp @/alg.stat `echo @|sed -e "s/raxml_/satetree_/g"`'
find -name raxml_sate$*|xargs -I@ sh -c 'cp @/spfn.stat `echo @|sed -e "s/raxml_/satetree_/g"`'
find -name raxml_sate$*|xargs -I@ sh -c 'cp @/sate.stat `echo @|sed -e "s/raxml_/satetree_/g"`'
find -name raxml_sate$*|xargs -I@ sh -c 'cp @/reference.tre `echo @|sed -e "s/raxml_/satetree_/g"`'
echo "find -path *satetree_sate$** -name condor.mb -execdir condor_submit condor.mb \;"
