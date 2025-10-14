#!/bin/bash

#https://www.digitalocean.com/community/tutorials/how-to-set-up-a-help-desk-system-with-otrs-on-centos-7
#Creating a Docker Container on CentOS 7
#Operating Systen used: CentoOS 7
#Contain Type CentOS 7 x86
#Chad Perry

#Updates and Istall MariaDB
sudo yum update && upgrade
sudo yum install mariadb-server mariadb epel-release -y

#Update the Configuration File
echo "Add the following line under [mysqld]"
sudo vi  /etc/my.cnf under
max_allowed_packet = 20M
query_cache_size = 32M
innodb_log_file_size = 256M

sudo systemctl start mariadb.service
sudo mysql_secure_installation
wget http://ftp.otrs.org/pub/otrs/RPMS/rhel/7/otrs-5.0.7-01.noarch.rpm
sudo yum install otrs-5.0.7-01.noarch.rpm
sudo /opt/otrs/bin/otrs.CheckModules.pl
sudo yum install -y "perl(Apache2::Reload)" "perl(Crypt::Eksblowfish::Bcrypt)" \
"perl(Encode::HanExtra)" "perl(JSON::XS)" "perl(Mail::IMAPClient)" \
"perl(ModPerl::Util)" "perl(Text::CSV_XS)" "perl(YAML::XS)"
sudo systemctl restart httpd.service
echo "http://your_server_ip/otrs/installer.pl"
