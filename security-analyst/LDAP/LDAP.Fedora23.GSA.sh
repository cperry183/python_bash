#!bin/bash

#RPM's found here: ftp://pokgsa.ibm.com/projects/g/gsa/client/linux/

#Installation of Dependencies needed for GSA
#Yum command has been deprecated

sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install nss_ldap nfs-utils  portmap  autofs -y
sudo dnf install /usr/bin/perl -y
sudo dnf install /usr/bin/ldapsearch -y

#Installation of Global Storage Architecture
 sudo rpm -Uhv ftp://pokgsa.ibm.com/projects/g/gsa/client/linux/rhel6/gsa-client-3.0.15-4.x86_64.rpm

#Configuration of gsa
sudo /usr/bin/gsaclient_config

#GSA Linux client packages
#======================================================================

#The Linux GSA client packages are built for specific glibc versions.

#These packages have been built using the OC2.2 clients (glibc-2.5-24)
#and should install and function on systems running similar versions of
#glibc.

#For all other linux systems you will need to install the source rpm
#provided in this directory and build your own rpm package.

#Once the source rpm is installed you will need to find where the source
#was installed. Typically that would be /usr/src/redhat/.. on redhat
#systems and /usr/src/packages on Suse systems.  Within those directories
#you will find a SPEC directory which contains a gsa_client.spec file.
#To build the package you will need to issue the following command.

rpmbuild -ba gsa_client.spec
