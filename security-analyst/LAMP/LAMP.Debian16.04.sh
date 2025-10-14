#!/bin/bash

#Install Apache and Allow in Firewall
sudo apt-get update -y
sudo apt-get install apache2 curl wget -y
sudo ufw app info "Apache Full"

#Install MySQL
sudo apt-get install mysql-server -y
sudo mysql_secure_installation

#Installation of php
sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql -y

#Edit the configuration file
cd /etc/apache2/mods-enabled
rm -rf dir.conf
touch dir.conf
cat << EOM >> /etc/apache2/mods-enabled/dir.conf
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOM

sudo systemctl restart apache2
sudo systemctl status apache2
