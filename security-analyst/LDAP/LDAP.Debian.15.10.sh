!#/bin/bash

set -x

sudo apt-get install wget -y
wget http://ocdc.hursley.ibm.com/ocdc/pool/IBM/g/gsa-client/gsa-client_3.0.11-3+vivid_amd64.deb
wget http://ocdc.hursley.ibm.com/ocdc/pool/IBM/g/gsa-client/libnss-gsa_3.0.11-3+vivid_amd64.deb
wget http://ocdc.hursley.ibm.com/ocdc/pool/IBM/g/gsa-client/libpam-gsa_3.0.11-3+vivid_amd64.deb
chmod 444 *.deb
wget http://<HOSTNAME>/files/gsa-client.seed

sudo ln -s /bin/bash /usr/bin/bash
sudo apt-get install ksh

# Install pre-reqs
sudo apt-get install autofs ldap-utils auth-client-config -y

# Set auto-responses
sudo debconf-set-selections ./gsa-client.seed

# Install it
sudo dpkg -i *.deb

# Restart
sudo service gsanslcd restart
