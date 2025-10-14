#!/usr/bin/env bash 

yum update -y --disablerepo=* --enablerepo=centos-7*
yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el$(rpm --eval %rhel).noarch.rpm
yum install -y leapp-upgrade leapp-data-almalinux
leapp preupgrade 
leapp answer --section remove_pam_pkcs11_module_check.confirm=True
