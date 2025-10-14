#!/usr/bin/env bash 
set -x 

yum-config-manager --disable foreman_proxy
yum-config-manager --disable foreman_proxy-source
yum-config-manager --disable foreman_proxy-plugins
yum install -y java-1.8.0-openjdk-headless-1.8.0.372.b07-1.el7_9.x86_64 --enablerepo=centos-7-os --enablerepo=centos-7-updates;
yum install -y java-1.8.0-openjdk-1.8.0.372.b07-1.el7_9.x86_64 --enablerepo=centos-7-os --enablerepo=centos-7-updates;
for X in restart status; do systemctl $X puppetserver; done 
