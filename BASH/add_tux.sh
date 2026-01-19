#!/usr/bin/env bash 

cat << EOF >> /etc/yum.repos.d/els-updates.repo
[els-updates]
name=Tuxcare ELS Updates
baseurl=http://yumrepos.med.harvard.edu/centos-7/els/updates/x86_64/
enabled=1
gpgcheck=0
EOF

yum update --disablerepo=* --enablerepo=els-* --exclude=puppet-agent --exclude=sensu
yum clean all
