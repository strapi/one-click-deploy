#!/bin/bash -e

# disable default nginx configs
echo "Disabling default Nginx config"
rm /etc/nginx/sites-enabled/default

# move strapi config to nginx and create symlink
echo "Configuring Strapi Nginx Proxy"
mv /tmp/nginx/strapi.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/strapi.conf /etc/nginx/sites-enabled/
mv /tmp/nginx/upstream.conf /etc/nginx/conf.d/
systemctl -q restart nginx

# create the strapi user
echo "Creating the Strapi service user"
adduser --home /srv/strapi --shell /bin/bash --disabled-login --gecos "" --quiet strapi