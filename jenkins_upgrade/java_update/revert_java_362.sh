#!/usr/bin/env bash 
set -x 

BACKUP_DATE="$(date +%Y-%m-%d)"

# Stop services 
systemctl stop jenkins; systemctl status jenkins 
puppet agent --disable "java update"

# Install an alternate version of java
sudo rpm -ivh --oldpackage /home/chp6694/java_rpm/java-1.8.0-openjdk-headless-1.8.0.362.b08-1.el7_9.x86_64.rpm
sudo rpm -ivh --oldpackage /home/chp6694/java_rpm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64.rpm

# change java version 
sudo update-alternatives --config java

# restart services
cp -ra /var/lib/jenkins-${BACKUP_DATE} /var/lib/jenkins
for H17 in start status; do systemctl ${H17} jenkins;done
puppet agent -t --enable
java -version
