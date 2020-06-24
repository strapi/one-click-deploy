#!/bin/bash

LOG=/srv/strapi/install.log

# fetch public IP for proxy
IP=$(curl -s ifconfig.me)

# generate new database password and dump to a temp file for strapi install
PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

# create strapi user in pg
echo "Creating User in PG" >> $LOG
su - postgres -c "psql -c \"create user strapi;\"" 

# create strapi database in pg
echo "Creating Database in PG" >> $LOG
su - postgres -c "psql -c \"create database strapi;\""

# setting strapi password and permissons
echo "Setting passwords and permissions in PG" >> $LOG
su - postgres -c "psql -c \"alter user strapi with encrypted password '$PASS';\""
su - postgres -c "psql -c \"grant all privileges on database strapi to strapi;\""

# install strapi with PostgreSQL using the Strapi UUID prefix
echo "Creating Strapi project" >> $LOG
cd /srv/strapi; STRAPI_UUID_PREFIX="DO-" npx create-strapi-app@latest strapi-development \
--dbclient=postgres \
--dbhost="127.0.0.1" \
--dbport=5432 \
--dbname="strapi" \
--dbusername="strapi" \
--dbpassword="$PASS" \
--dbforce

# move files
echo "Moving some files for Strapi" >> $LOG
mv /srv/strapi/server.js /srv/strapi/strapi-development/config/
echo "NGINX_URL=http://${IP}" > /srv/strapi/strapi-development/.env

# build the adminUI
echo "Building the Strapi admin" >> $LOG
cd /srv/strapi/strapi-development; yarn build --no-optimizations > /dev/null

# ensure the strapi user owns the data dir
echo "Changing ownership" >> $LOG
chown -R strapi:strapi /srv/strapi

# spinup the server and set to run on boot
echo "Starting Strapi" >> $LOG
su - strapi -c "cd /srv/strapi/strapi-development && pm2 start npm --name strapi-development -- run develop > /dev/null"
sleep 30

# run strapi on boot
echo "Set Strapi to run on boot" >> $LOG
env PATH=$PATH:/usr/bin /usr/local/share/.config/yarn/global/node_modules/pm2/bin/pm2 startup systemd -u strapi --hp /srv/strapi > /dev/null
su - strapi -c "pm2 save > /dev/null"

echo "Install Complete" >> $LOG

cp $LOG /root/ && rm $LOG
