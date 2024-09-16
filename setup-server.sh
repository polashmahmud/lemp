#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Install MariaDB
sudo apt install -y mariadb-server
sudo mysql_secure_installation