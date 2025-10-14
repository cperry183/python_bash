
####################################################
#	 Program: Add a Machine to Nagios
#	 Script Name: Nagios-Add.sh
# 	 Developer: Chad Perry
# 	 Date: 04-21-2016
# 	 Last Updated: 04-21-2016
###################################################

#!/bin/sh 

apt-get update
apt-get install nagios-nrpe-server nagios-nrpe-plugin -y
groupadd nrpe
useradd -g nrpe nrpe
mkdir /run/nrpe
chown nrpe.nrpe /run/nrpe
wget http://arlab093.austin.ibm.com/files/nrpe.cfg
mv nrpe.cfg /etc/nagios/.
sysctl start nagios-nrpe-server
echo "After the script is finished please run this commands on arl29"
echo "nagios3 -v /etc/nagios3/nagios.cfg"
echo "cat /etc/nagios3/nagios3.cfg"
echo "You should see your machine"

<Curl Command to pull from arlab172.austin.ibm.com>  
		bash <(curl -s http://arlab172.austin.ibm.com/var/www/Curl/Nagios-Add.sh)