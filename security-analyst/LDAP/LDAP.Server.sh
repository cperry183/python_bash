#!/bin/bash
#

####################################################################
#	 Program: Configure and Install OpenLDAP And phpLDAP Admin
#	 Script Name: LDAP.sh
# 	 Developer: Chad Perry
#    OS Version Ubuntu Server 15.10
# 	 Date: 05-09-2016
# 	 Last Updated: 05-09-2016
####################################################################
#
#Install LDAP and Helper Utilities
#
sudo apt-get update
sudo apt-get install slapd ldap-utils -y
#
#Reconfigure slapd for your Enviroment
sudo dpkg-reconfigure slapd
#Answers to questions asked
#Omit OpenLDAP server configuration? No
#Omit OpenLDAP server configuration? No
#DNS domain name?
#Organization name?
#Database backend? HDB
#Remove the database when slapd is purged? No
#Move old database? Yes
#Allow LDAPv2 protocol? No
#
#Installation of phpAdmin and Web-Interface
sudo apt-get install phpldapadmin -y
#
#Configure phpLDAPadmin
vi /etc/phpldapadmin/config.php
$servers->setValue('server','host','x.x.x.x');
$servers->setValue('server','base',array('dc=xxx,dc=com'));
$servers->setValue('login','bind_id','cn=admin,dc=ibm,dc=com');
$config->custom->appearance['hide_template_warning'] = true;
#
#Create an SSL Certificate
sudo mkdir /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout
/etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
#Country Name (2 letter code) [AU]:us
#State or Province Name (full name) [Some-State]:Texas
#Locality Name (eg, city) []:Austin
#Organization Name (eg, company) [Internet Widgits Pty Ltd]:IBM
#Organizational Unit Name (eg, section) []:
#Common Name (e.g. server FQDN or YOUR name) []:9.3.158.172
#Email Address []:chadp@us.ibm.com
#
#Create a Password Authentication File
sudo apt-get install apache2-utils -y
sudo htpasswd -c /etc/apache2/htpasswd <username>
#
#Secure Apache
sudo a2enmod ssl
service apache2 restart
service apache2 status
#
#Modify the phpLDAPadmin Apache Configuration
vi /etc/phpldapadmin/apache.conf
<IfModule mod_alias.c>
    Alias /muypseirbea /usr/share/phpldapadmin/htdocs
</IfModule>
#
#Configure the HTTP Virtual Host
vi /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@arlab172.austin.ibm.com
    DocumentRoot /var/www/html
    ServerName arlab172.austin.ibm.com
    Redirect permanent /muypseirbea  https://arlab172.austin.ibm.com/muypseirbea
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
#
#Configure the HTTPS Virtual Host File
#
sudo a2ensite default-ssl.conf
service apache2 reload
#
#Edit the configuration file
#
/etc/apache2/sites-enabled/default-ssl.conf
ServerAdmin webmaster@arlab172.austin.ibm.com
ServerName arlab172.austin.ibm.com
SSLCertificateFile /etc/apache2/ssl/apache.crt
SSLCertificateKeyFile /etc/apache2/ssl/apache.key
#
#Add this to the end of the file
#
<Location /muypseirbea>
    AuthType Basic
    AuthName "Restricted Files"
    AuthUserFile /etc/apache2/htpasswd
    Require valid-user
</Location>
#
#Restart Apache2
service apache2 restart
service apache2 status

#Site Reference
https://www.digitalocean.com/community/tutorials/how-to-install-
and-configure-openldap-and-phpldapadmin-on-an-ubuntu-14-04-server
