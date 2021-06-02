#!/bin/bash -x


S3BUCKET='upgrad-ankit' 
NAME='ANKIT'
sudo apt update -y

sudo apt query apache2

if [[ $? != 0 ]]; then
   sudo apt install apache2 -y
fi


service apache2 status

if [[ $? != 0 ]]; then
    service apache2 start
    service apache2 enable
fi

TIMESTAMP=$(date '+%d%m%Y-%H%M%S')
tar -cvf /tmp/$NAME-httpd-logs-$TIMESTAMP.tar /var/log/apache2/*.log

filen=`du -h /tmp/$NAME-httpd-logs-$TIMESTAMP.tar`
size=`echo $filen |cut -d " " -f1`

aws s3 \
cp /tmp/$NAME-httpd-logs-${TIMESTAMP}.tar \
s3://${S3BUCKET}/$NAME-httpd-logs-${TIMESTAMP}.tar

ls -ltrh /tmp/*ANKIT*.tar|cut -d " " -f5,10 > /tmp/text

if [[ -f /var/www/html/inventory.html ]]; then
   echo -e "httpd-logs\t $TIMESTAMP \ttar \t $size" >>/var/www/html/inventory.html
else
   echo -e "Log Type \tTime Created \t\tType \t Size" > /var/www/html/inventory.html
   while read p; do
      secstr=`echo $p |cut -d " " -f2` 
      firstr=`echo $p|cut -d " " -f1`
      LOGTY=`echo $secstr |cut -d "-" -f2,3`
      TIMECR=`echo $secstr|cut -d "-" -f4,5|cut -d "." -f1`
      TYPE=`echo $secstr|cut -d "." -f2`
      echo -e "$LOGTY \t$TIMECR \t$TYPE \t$firstr" >>/var/www/html/inventory.html
   done </tmp/text
fi
