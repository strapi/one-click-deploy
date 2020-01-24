#!/bin/bash -e

# load temp password from database script
PASS=$(cat /srv/strapi/temp_pgpass)

# install strapi with PostgreSQL
echo "Creating the Strapi application"
cd /srv/strapi; yarn create strapi-app strapi \
--dbclient=postgres \
--dbhost="127.0.0.1" \
--dbport=5432 \
--dbname="strapi" \
--dbusername="strapi" \
--dbpassword="$PASS" \
--dbforce

# build the adminUI
echo "Building the AdminUI"
cd /srv/strapi/strapi; yarn build > /dev/null

# move config files
echo "Moving Strapi config files and scripts"
mv /tmp/strapi/index.html /srv/strapi/strapi/public/
mv /tmp/strapi/server.json /var/lib/cloud/scripts/per-instance/
mv /tmp/strapi/set-strapi-ip.sh /srv/strapi
chmod +x /srv/strapi/set-strapi-ip.sh

# ensure the strapi user owns the data dir
echo "Ensuring Strapi owns all needed files and directories"
chown -R strapi:strapi /srv/strapi

# spinup the server and set to run on boot
echo "Starting Strapi to generate any automated files"
su - strapi -c "cd /srv/strapi/strapi && pm2 start npm --name strapi-develop -- run develop > /dev/null"
sleep 30
echo "Enabling proxy IP setup cronjob for first boot"
su - strapi -c "crontab /srv/strapi/strapi-cron"
su - strapi -c "rm /srv/strapi/strapi-cron"

# run strapi on boot
echo "Setting Strapi to run on boot"
sudo env PATH=$PATH:/usr/bin /usr/local/share/.config/yarn/global/node_modules/pm2/bin/pm2 startup systemd -u strapi --hp /srv/strapi > /dev/null
su - strapi -c "pm2 save > /dev/null"

# cleanup temp_pgpass
rm /srv/strapi/temp_pgpass