#!/bin/bash

# Define hostname
HN=wordpress.amaldeep.tech

# Define MySQL root password  ======== REPLACE WITH STRONG PASSWORD ======== 
DB_ROOT_PASS=abc@123

# Define wordpress database name
DB=wordpress 

# Define wordpress database username
DB_USER=wpuser

# Define wordpress database password  ======== REPLACE WITH STRONG PASSWORD ========
DB_PASS=abc@123

# Set hostname
hostnamectl set-hostname $HN

# yum update
yum update -y

# install httpd, php, mariadb 
yum install httpd mariadb-server -y 
amazon-linux-extras install php7.4  -y 

# enable httpd and mariadb services
systemctl enable httpd.service
systemctl restart httpd.service
systemctl enable mariadb.service
systemctl restart mariadb.service

# Download latest wordpress and upload to document root
wget https://wordpress.org/latest.zip -P /var/www/html/
unzip /var/www/html/latest.zip  -d /var/www/html/
mv /var/www/html/wordpress/* /var/www/html/ 
mv /var/www/html/wp-config-sample.php  /var/www/html/wp-config.php

# Remove zip file and extracted directory  
rm -r /var/www/html/latest.zip
rm -rf /var/www/html/wordpress


### mysql_secure_installation
# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$DB_ROOT_PASS') WHERE User = 'root'"

# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"

# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"

# Kill off the demo database
mysql -e "DROP DATABASE test"

# Wordpress db and user creation 
mysql -e "create database $DB"
mysql -e "create user '$DB_USER'@'localhost' identified by '$DB_PASS'"
mysql -e "grant all privileges on $DB.* to '$DB_USER'@'localhost'"

# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"

# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param


# Update wp-config 
sed -i "s/database_name_here/$DB/" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASS/" /var/www/html/wp-config.php

# Reset document root ownership 
chown -R apache.apache /var/www/html/

