#!/usr/bin/env bash 
set -x 

VERSION_NUMBER="2.419"

systemctl stop jenkins
puppet agent --disable "upgrading jenkins"
cp -ra /var/lib/jenkins /var/lib/jenkins-${VERSION_NUMBER}
yum update jenkins-${VERSION_NUMBER}
systemctl start jenkins
systemctl status jenkins -l
puppet agent -t --enable
