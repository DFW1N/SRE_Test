#============================================================================#
#                                                                            #
#                       Date Created: 20/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

sudo apt-get update -y

sudo apt-get install nginx -y

sudo mkdir -p /var/www/html

cat <<EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Hello, World!</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <!-- I hope you didnt you didnt inspect my awesome website! :(  -->
</body>
</html>
EOF


sudo mkdir -p /etc/nginx/ssl/
touch /home/adminuser/.rnd

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx-selfsigned.key \
  -out /etc/nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=AU/ST=QLD/L=Brisbane/O=SachaOrganisation/CN=localhost"

sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

sudo tee /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    server_name _;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl default_server;
    server_name _;

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # Additional SSL configuration options go here...

    location / {
        root /var/www/html;
        index index.html;
    }
}
EOF

sudo systemctl restart nginx

sudo systemctl start nginx

sudo systemctl enable nginx

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

sudo systemctl status nginx