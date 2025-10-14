#!/bin/bash

# ******************************************
#	 Program: LAMP Stack Installation Script
#	 Script Name: lamp-installation.sh
# 	 Developer: Chad Perry
# 	 Date: 01-02-2016
# 	 Last Updated: 01-02-2016
# ******************************************
#
#!/bin/bash
#LAMP Stack on Ubuntu
#
sudo apt-get -y update;
sudo apt-get -y install mysql-server mysql-client mysql-workbench libmysqld-dev unzip
sudo apt-get -y install php5 libapache2-mod-php5 php5-mcrypt phpmyadmin;
#
#Installation of Appitude
#
sudo apt-get install aptitude
#
#Stuff Need to Install Mod_wsgi
sudo aptitude install apache2 apache2.2-common apache2-mpm-prefork apache2-utils libexpat1 ssl-cert
#
#Installation of Mod_wgsi
sudo aptitude install libapache2-mod-wsgi
#
#Restarting Services and Testing
#
sudo chmod 775 -R /var/www/;
sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
sudo service apache2 restart;
/usr/bin/mysql_secure_installation;
#
____________________________________________________________________________________________
#!/bin/bash
#LAMP STackk CentOS
#
sudo yum -y install httpd mysql-server mysql-devel php php-mysql php-fpm;
sudo yum -y install epel-release phpmyadmin rpm-build redhat-rpm-config;
sudo yum -y install mysql-community-release-el7-5.noarch.rpm proj;
sudo yum -y install tinyxml libzip mysql-workbench-community;
sudo chmod 777 -R /var/www/;
sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
sudo service mysqld restart;
sudo service httpd restart;
sudo chkconfig httpd on;
sudo chkconfig mysqld on;
#______________________________________________________________________________________
#!/bin/bash

##!/bin/bash

# ******************************************
#	 Program: LAMP Stack Installation Script
#	 Script Name: lamp-installation.sh
# 	 Developer: Chad Perry
# 	 Date: 01-02-2016
# 	 Last Updated: 01-02-2016
# ******************************************
#
#!/bin/bash
#LAMP Stack on Ubuntu
#
sudo apt-get -y update;
sudo apt-get -y install mysql-server mysql-client mysql-workbench libmysqld-dev;
sudo apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt phpmyadmin;
sudo chmod 775 -R /var/www/;
sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
sudo service apache2 restart;
#
#_____________________________________________________________________________________
#!/bin/bash
#LAMP STackk CentOS
#
sudo yum -y install httpd mysql-server mysql-devel php php-mysql php-fpm;
sudo yum -y install epel-release phpmyadmin rpm-build redhat-rpm-config;
sudo yum -y install mysql-community-release-el7-5.noarch.rpm proj;
sudo yum -y install tinyxml libzip mysql-workbench-community;
sudo chmod 777 -R /var/www/;
sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
sudo service mysqld restart;
sudo service httpd restart;
sudo chkconfig httpd on;
sudo chkconfig mysqld on;
