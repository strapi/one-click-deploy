#!/bin/bash -e

# disable default nginx configs
echo "Disabling default Nginx config"
sudo rm /etc/nginx/sites-enabled/default

# move strapi config to nginx and create symlink
echo "Configuring Strapi Nginx Proxy"
sudo mv /tmp/nginx/strapi.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/strapi.conf /etc/nginx/sites-enabled/
sudo mv /tmp/nginx/upstream.conf /etc/nginx/conf.d/
sudo systemctl -q restart nginx

# create the strapi user
echo "Creating the Strapi service user"
sudo mkdir -p /srv/strapi
sudo adduser --home /srv/strapi --shell /bin/bash --disabled-login --gecos "" --quiet strapi
sudo chown -R strapi:strapi /srv/strapi

# move strapi motd script
echo "Moving Strapi MOTD add-on script"
sudo mv /tmp/system/99-strapi-motd /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/99-strapi-motd

# move upstart script
echo "Move startup script to cloud-init"
sudo mv /tmp/strapi/setup_strapi.sh /var/lib/cloud/scripts/per-instance/
sudo chmod +x /var/lib/cloud/scripts/per-instance/setup_strapi.sh

# move some strapi files to staging area
echo "Moving some Strapi files to staging"
mv /tmp/strapi/server.js /srv/strapi/