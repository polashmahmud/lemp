#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install -y nginx

# Install MariaDB
sudo apt install -y mariadb-server
sudo mysql_secure_installation

# Install PHP
sudo apt install -y php-fpm php-mysql

# Install PHP extensions
sudo apt-get install -y php-cli php-common php-zip php-gd php-mbstring php-curl php-xml php-bcmath

# Install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

# Add new user (replace 'username' with your desired username)
sudo adduser username

# Change nginx and PHP user settings
sudo nano /etc/nginx/nginx.conf
sudo nano /etc/php/8.2/fpm/pool.d/www.conf

# Install Git
sudo apt install -y git

# Nginx site configuration (replace with your project path)
sudo bash -c "cat > /etc/nginx/sites-enabled/site-name <<EOF
server {
    root /yourproject-path;
    index index.php index.html index.htm;
    server_name example.com www.example.com;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    location ~ /\.ht {
        deny all;
    }
}
EOF"

# Test Nginx configuration and restart service
sudo nginx -t
sudo systemctl restart nginx

# Install SSL certificate with Certbot (replace domain)
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com
