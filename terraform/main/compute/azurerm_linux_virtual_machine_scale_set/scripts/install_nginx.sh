#============================================================================#
#                                                                            #
#                       Date Created: 20/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

# Update the package manager
sudo apt-get update -y

# Install Nginx
sudo apt-get install nginx -y

# Create a directory for the webpage
sudo mkdir -p /var/www/html

# Create a file called index.html with the following contents
echo "Hello, World!" | sudo tee /var/www/html/index.html

# Start Nginx
sudo systemctl start nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Open port 80 in the firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Verify that Nginx is running
sudo systemctl status nginx