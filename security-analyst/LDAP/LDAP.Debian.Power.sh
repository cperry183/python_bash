#!/bin/bash

mkdir -p ~/gsa
cd ~/gsa
sudo apt-get -y install auth-client-config autofs ksh ldap-utils openssl libldap-dev libssl-dev libpam-dev rpm2cpio debhelper
wget http://ocdc.hursley.ibm.com/ocdc/pool/IBM/g/gsa-client/gsa-client_3.0.11-3.tar.gz
tar -xfv gsa-client_3.0.11-3.tar.gz
wget http://arlab093.austin.ibm.com/blog/wp-content/uploads/2015/12/patch-gsa-client-debian-rules.patch
patch -p0 < patch-gsa-client-debian-rules.patch

cd gsa-client-3.0.11/
fakeroot debian/rules binary

cd ..
wget http://<HOSTNAME>/files/gsa-client.seed  #CONFIGURE THIS FILE FOR YOUR ORGINAZATION

sudo debconf-set-selections ./gsa-client.seed
sudo dpkg -i *.deb
sudo service gsanslcd restart
[ ! -e /usr/bin/bash ] && sudo ln -sf $(which bash) /usr/bin/bash
