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

aws s3 \
cp /tmp/$NAME-httpd-logs-${TIMESTAMP}.tar \
s3://${S3BUCKET}/$NAME-httpd-logs-${TIMESTAMP}.tar

