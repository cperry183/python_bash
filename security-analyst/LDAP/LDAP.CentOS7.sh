#!bin/bash

#RPM's found here: ftp://pokgsa.ibm.com/projects/g/gsa/client/linux/

#Installation of Dependencies needed for GSA
#Yum command has been deprecated

sudo yum update -y
sudo yum upgrade -y
sudo yum install nss_ldap nfs-utils  portmap  autofs perl ldapsearch ksh -y
sudo yum install expect bind-utils krb5-workstation -y
sudo yum install /usr/bin/ldapsearch

#Installation of Global Storage Architecture
sudo rpm -Uhv ftp://pokgsa.ibm.com/projects/g/gsa/client/linux/rhel7/gsa-client-3.0.15-5.el7.x86_64.rpm

#Configure GSA
sudo /usr/bin/gsaclient_config
