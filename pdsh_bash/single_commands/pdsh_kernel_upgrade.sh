#!/usr/bin/env bash 
set -x 

GROUP=$1"
CMD="$2"
PACK="$3"

timestamp=$(date +"%Y%m%d")

mkdir -p /home/chp6694/vuln_artifacts/vul_logs_${timestamp}
pdsh -g ${GROUP} 'yum update --disablerepo=* --enablerepo=centos-7* kernel -y' 
mv /tmp/${PACK}.log /home/chp6694/vuln_artifacts/vul_logs_${timestamp}

