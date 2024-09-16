#!/usr/bin/env bash
# LEMP Server Setup Script
# Author: Polash Mahmud

if dpkg-query -W needrestart >/dev/null 2>&1; then
    sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
fi

echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4

# Update and Upgrade system
sudo apt update && sudo apt upgrade -y

# Add PHP Repository
sudo apt-get install ca-certificates apt-transport-https software-properties-common
sudo add-apt-repository ppa:ondrej/php -y

# Update and Upgrade system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Install MariaDB
sudo apt install mariadb-server mariadb-client -y
sudo mysql_secure_installation

# Install PHP
sudo apt install php8.3-fpm php8.3-mysql

# Install PHP Extensions
sudo apt install php8.3-mysql php8.3-imap php8.3-ldap php8.3-xml php8.3-curl php8.3-mbstring php8.3-zip

# Install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

# Move Composer to bin
sudo mv composer.phar /usr/local/bin/composer

# Add new user (replace 'deploy' with your desired username)
sudo adduser deploy

# Change nginx and PHP user to new user
sudo sed -i 's/user www-data;/user deploy;/g' /etc/nginx/nginx.conf
sudo sed -i 's/user = www-data/user = deploy/g' /etc/php/8.3/fpm/pool.d/www.conf
sudo sed -i 's/group = www-data/group = deploy/g' /etc/php/8.3/fpm/pool.d/www.conf

# Restart Nginx and PHP
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm

# Install Git
sudo apt install git -y

# Nginx site configuration file (replace 'api' with your domain)
sudo bash -c 'cat > /etc/nginx/sites-available/api <<EOF
server {
    root /home/deploy/api/public;
    index index.php index.html index.htm;
    server_name api.ibanklegal.com www.ibanklegal.com;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    location ~ /\.ht {
        deny all;
    }
}

server {
    listen 80;
    listen [::]:80;
}

EOF'

# Enable site
sudo ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/

# Restart Nginx
sudo nginx -t
sudo systemctl restart nginx

# Switch to new user
su - deploy

# Create api project folder and index.php file
mkdir -p ~/api/public
echo "<?php phpinfo();" > ~/api/public/index.php

# Switch back to root
exit



