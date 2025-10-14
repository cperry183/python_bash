#!/bin/bash

#Ubuntu 15.10

#Part 1
#https://www.digitalocean.com/community/tutorials/how-to-use-kpcli-to-manage-keepass2-password-files-on-an-ubuntu-14-04-server

#Part 2
#https://www.digitalocean.com/community/tutorials/how-to-serve-a-keepass2-password-file-with-nginx-on-an-ubuntu-14-04-server


#Install Necessary Components
sudo apt-get update - y
sudo apt-get install kpcli libterm-readline-gnu-perl libdata-password-perl -y

#Starting the Session and Getting Oriented
kpcli
saveas password_database.kdbx
echo "passw0rd"

#Install Nginx
sudo apt-get update -y
sudo apt-get install nginx -y

#Create SSL Certificates
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

#Create a Password File
sudo apt-get install apache2-utils -y
echo "Use the same password as you did from above"
sudo htpasswd -c /etc/nginx/htpasswd  ubuntu

#Create a Web Directory
mkdir ~/secure_html
mv ~/password_database.kdbx ~/secure_html
sudo chown www-data:www-data ~/secure_html
sudo chmod 2770 ~/secure_html
sudo usermod -aG www-data ubuntu
sudo chown :www-data ~/secure_html/*
echo "Logout of the server"

#Configure Nginx Server Blocks
cat << EOM >>  /etc/nginx/sites-available/default
server {
    listen 443;
    listen [::]:443 ipv6only=on ssl;
    server_name arlz198.austin.ibm.com;

    access_log /var/log/nginx/access.log;
    root /home/ubuntu/secure_html;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        auth_basic "Restricted";
        auth_basic_user_file "/etc/nginx/htpasswd";

        dav_methods PUT DELETE MOVE COPY;
        dav_access group:rw all:r;
    }
}
EOM

#Restart ngnix
systemctl restart nginx.service
systemctl status  nginx.service

#Download and Install KeePass2 on your Local Computer
echo "Please follow this link to install MacOSX KeePassX 2.*"
echo  "http://arlx032.austin.ibm.com/2016/07/18/password-vault/"
