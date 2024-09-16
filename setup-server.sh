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
