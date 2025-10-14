#!/usr/bin/env bash
set -x

BACKUP_DATE="$(date +%Y-%m-%d)"

# Disable dead repo's
yum-config-manager --disable foreman_proxy
yum-config-manager --disable foreman_proxy-source
yum-config-manager --disable foreman_proxy-plugins

# Stop services 
systemctl stop jenkins; systemctl status jenkins 
puppet agent --disable "java update"
cp -ra /var/lin/jenkins /var/lib/jenkins-${BACKUP_DATE} 

# update java 
yum install java-1.8.0-openjdk-headless-1.8.0.372.b07-1.el7_9.x86_64 --enablerepo=centos-7-os --enablerepo=centos-7-updates;
yum install java-1.8.0-openjdk-1.8.0.372.b07-1.el7_9.x86_64 --enablerepo=centos-7-os --enablerepo=centos-7-updates;

# restart services
for H17 in start status; do systemctl ${H17} jenkins;done
puppet agent -t --enable
java -version
