#~/bin/sh

s=0
while [ 1 ]; do 
   m=`/bin/ps -o "rss=" -$1|sort -n -r|tr '\n' ','|sed -e "s/,$//g"`;
   sn=$((${m//,/+}));
   d=$(($sn - $s));
   if [ $d -gt $2 ] || [ $(($s - $sn)) -gt $2 ]; then
        s=$sn;
        echo `date`: $(( $s / 1024 ))"M ("$(( $d / 1024 ))"M) ||" $m; 
   fi
   sleep 1;
done
