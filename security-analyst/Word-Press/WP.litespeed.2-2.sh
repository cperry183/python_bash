#!/bin/bash
#
# ******************************************
#	 Program: Installation of WP
#	 Script Name: WP-Install2.2.sh 
# 	 Developer: Chad Perry
# 	 Date: 04-13-2016
# 	 Last Updated: 04-13-2016
# ******************************************
#
#Prepare the Virtual Host and Document Root Directories
#
echo "Cleaning the Virtual Host and Root Directories"
cd /usr/local/lsws/DEFAULT; 
rm -rf cgi-bin fcgi-bin;
rm cgi-bin/* fcgi-bin/*; 
rm conf/ht*; 
rm -rf html/*; 
#
#Installation of Word Press
echo "Installing Word Press"
cd ~;
wget https://wordpress.org/latest.tar.gz;
tar xzvf latest.tar.gz;
cd wordpress;
cp wp-config-sample.php wp-config.php; 
#
#Editing the Word Press Configuration File
#
echo "Now we are editing the Word Press Configuration file"
#Edit the wp-config.php
sed -i "/DB_HOST/s/'[^']*'/'localhost'/2" wp-config.php;
sed -i "/DB_NAME/s/'[^']*'/'wordpress'/2" wp-config.php;
sed -i "/DB_USER/s/'[^']*'/'chadp'/2" wp-config.php;
sed -i "/DB_PASSWORD/s/'[^']*'/'BlueHonda1@32'/2" wp-config.php;