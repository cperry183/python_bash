#!/usr/bin/env bash 

yum update -y kernel-* --disablerepo=* --enablerepo=centos-7* 
yum info kernel 
uname -r 

