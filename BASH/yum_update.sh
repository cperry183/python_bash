#!/usr/bin/evn bash 

yum update --disablerepo=* --enablerepo=els-* --exclude=puppet-agent --exclude=sensu 
yum clean all 
