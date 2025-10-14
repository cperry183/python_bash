#Installation of LAMP Stack Ubuntu Server 16.04
#WP-Installation-UB16.sh
#Developer:   Chad Perry
#Reference: https://www.digitalocean.com/community/tutorials/
#how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-16-04
#!/bin/bash
#
#Installation of Apache and Allow Acess to 8080,443
sudo apt-get update
sudo apt-get install apache2
sudo ufw  allow in "Apache Full"
#
#Installation of MySQL and Common Security questions
sudo apt-get install mysql-server
sudo mysql_secure_installation
#
#Installation of PHP and Restarting Apache2
sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql
sudo systemctl restart apache2
sudo systemctl status apache2
echo "The LAMP Stack is now installed"


--------------------------------------------------------------------------------
mysql -u root -p
create database Chad's Blog;
GRANT ALL ON Chad's Blog.* TO 'chadp'@'localhost' IDENTIFIED BY 'BlueHonda1@32';
FLUSH PRIVILEGES;
exit

vi nano /etc/apache2/apache2.conf
<Directory /var/www/html/>
    AllowOverride All
</Directory>


sudo a2enmod rewrite
sudo apache2ctl configtest
sudo systemctl restart apache2

cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

touch /tmp/wordpress/.htaccess
chmod 660 /tmp/wordpress/.htaccess

cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sudo cp -a /tmp/wordpress/. /var/www/html

#Changing Permissions
sudo chown -R chadp:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod g+s {} \;
sudo chmod g+w /var/www/html/wp-content
sudo chmod -R g+w /var/www/html/wp-content/themes
sudo chmod -R g+w /var/www/html/wp-content/plugins

curl -s https://api.wordpress.org/secret-key/1.1/salt/

#wp-config File
vi /var/www/html/wp-config.php

define('DB_NAME', 'Chad's Blog');
define('DB_USER', 'chadp');
define('DB_PASSWORD', 'BlueHonda1@32');
