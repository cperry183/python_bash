#!bin/bash

#Installation of Dependencies needed for GSA
#Yum command has been deprecated

sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install nss_ldap nfs-utils  portmap  autofs -y
sudo dnf install /usr/bin/perl -y
sudo dnf install /usr/bin/ldapsearch -y

sudo sudo rpm -Uhv ftp://pokgsa.ibm.com/projects/g/gsa/client/linux/archive/2.9-1/gsa-client-2.9-1.x86_64.rpm

#Configuration of gsa
sudo /usr/bin/gsaclient_config
