#!/bin/bash

SERVER=/srv/strapi/strapi-development/config/environments/development/server.json
PACKAGE=/srv/strapi/strapi-development/package.json

# fetch public IP for proxy
IP=$(curl -s ifconfig.me)

# generate new database password and dump to a temp file for strapi install
PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

# create strapi user in pg
sudo su - postgres -c "createuser strapi > /dev/null" 

# create strapi database in pg
sudo su - postgres -c "createdb strapidev > /dev/null"

# setting strapi password and permissons
sudo su - postgres -c "psql -c \"alter user strapi with encrypted password '$PASS';\""
sudo su - postgres -c "psql -c \"grant all privileges on database strapidev to strapi;\""

# install strapi with PostgreSQL
cd /srv/strapi; yarn create strapi-app strapi-development \
--dbclient=postgres \
--dbhost="127.0.0.1" \
--dbport=5432 \
--dbname="strapi" \
--dbusername="strapidev" \
--dbpassword="$PASS" \
--dbforce

# move files and configure proxy
sudo mv /srv/strapi/index.html /srv/strapi/strapi-development/public/
sudo mv /srv/strapi/server.json /srv/strapi/strapi-development/config/environments/development/
sudo su - strapi -c "sed -i s/changeme/$IP/g $SERVER"

# build the adminUI
cd /srv/strapi/strapi-development; yarn build --no-optimizations > /dev/null

# ensure the strapi user owns the data dir
chown -R strapi:strapi /srv/strapi

# spinup the server and set to run on boot
sudo su - strapi -c "cd /srv/strapi/strapi-development && pm2 start npm --name strapi-development -- run develop > /dev/null"
sleep 30

# run strapi on boot
sudo env PATH=$PATH:/usr/bin /usr/local/share/.config/yarn/global/node_modules/pm2/bin/pm2 startup systemd -u strapi --hp /srv/strapi > /dev/null
su - strapi -c "pm2 save > /dev/null"
