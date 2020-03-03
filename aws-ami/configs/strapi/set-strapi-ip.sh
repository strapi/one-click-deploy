#!/bin/bash

# Used to set Strapi proxy IP and change UUID on first boot, you can safely delete this script
SERVER=/srv/strapi/strapi/config/environments/development/server.json
PACKAGE=/srv/strapi/strapi/package.json

IP=$(curl -s ifconfig.me)
UUID=$(uuidgen)

if [ -f "$PACKAGE" ]; then
  su - strapi -c "sed -i 's/\"uuid\":.*/\"uuid\": \"'$UUID'\"/g' $PACKAGE"
  chown -R strapi:strapi /srv/strapi
fi

if [ -f "$SERVER" ]; then
  su - strapi -c "sed -i s/changeme/$IP/g $SERVER"
  su - strapi -c "pm2 restart strapi-develop"
  sleep 10
  chown -R strapi:strapi /srv/strapi
  rm -Rf /var/log/ufw.log
fi