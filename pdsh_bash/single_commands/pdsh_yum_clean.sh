#!/usr/bin/env bash 
set -x 

GROUP="$1"

timestamp=$(date +"%Y%m%d")

pdsh -g ${GROUP} 'yum clean all --disablerepo=* --enablerepo=centos-7*' 
