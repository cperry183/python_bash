#!/usr/bin/env bash 
set -x 

BEVN="$1"

puppet agent --enable 
puppet agent -t --environment=$BEVN 
systemctl start consul
systemctl enable consul 

sleep 3m 
nslookup $HOSTNAME |grep Address|sort -u
