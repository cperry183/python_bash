#!/usr/bin/env bash 

yum install wget git java-11-openjdk-devel -y
yum install jenkins-2.394-1.1 -y 
for x in start enable
do 
  systemctl $x jenkins
done


