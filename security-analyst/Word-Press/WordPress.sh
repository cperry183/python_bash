#!/bin/bash 
#	 Script Name: WP-Install1.2.sh 
# 	 Developer: Chad Perry
# 	 Date: 04-13-2016
# 	 Last Updated: 04-13-2016
# ******************************************
#Installation of Necessary Applications
#    
apt-get -y update;
#
#Installation of Apache2
#
apt-get install apache2 -y 
#
#Installation of OpenLite
apt-get install build-essential libexpat1-dev libgeoip-dev libpng-dev libpcre3-dev libssl-dev libxml2-dev rcs zlib1g-dev -y; 
#
#Compile and Install Open-Lite Speed
cd ~;
wget http://open.litespeedtech.com/packages/openlitespeed-1.3.10.tgz;
tar xzvf openlitespeed*;
cd openlitespeed*;
./configure;
make;
make install;
#
#Install and Configure MySQL
apt-get install mysql-server;

#Set the Administrative Password and Start Open-Lite Speed
/usr/local/lsws/admin/misc/admpass.sh; 
service lsws start; 
echo "Now you can view the defualt web-site"
echo  "http://your_domain_name_or_IP:8088"

#Setting MySQL
echo "Time to setup a database because Word Press requires it"
echo -n "Enter the MySQL root password: "
read -s rootpw
echo -n "Enter database name: "
read dbname
echo -n "Enter database username: "
read dbuser
echo -n "Enter database user password: "
read dbpw
 
db="create database $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u root -p$rootpw -e "$db"
 
if [ $? != "0" ]; then
 echo "[Error]: Database creation failed"
 exit 1
else
 echo "------------------------------------------"
 echo " Database has been created successfully "
 echo "------------------------------------------"
 echo " DB Info: "
 echo ""
 echo " DB Name: $dbname"
 echo " DB User: $dbuser"
 echo " DB Pass: $dbpw"
 echo ""
 echo "------------------------------------------"
fi
#Installation of PHP
apt-get install apt-get install libgd-dev libmcrypt-dev libcurl4-openssl-dev -y; 
/etc/init.d/apache2 restart;
#
#Web-Site Compiling of Open-Lite Speed
echo "Lets go to this web-site to compile Open-Lite"
echo "https://ipv4:7080"
echo "follow this guide to complete"
echo "https://cloud.digitalocean.com/support/suggestions?article=how-to-install-wordpress-with-openlitespeed-on-ubuntu-14-04&page=1&query=word%20press%20install%20ubuntu"
echo "Ten to fifteen minute break from the terminal"
echo "Please run the following command from your terminal"
echo "/usr/local/lsws/phpbuild/buildphp_manual_run.sh"
