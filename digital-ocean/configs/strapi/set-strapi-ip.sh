#!/bin/bash

# Used to set Strapi proxy IP on first boot, you can safely delete this script
SERVER=/srv/strapi/strapi/config/environments/development/server.json
IP=$(curl -s ifconfig.me)

if [ -f "$SERVER" ]; then
  sed -i "s/changeme/$IP/g" "$SERVER"
  rm "$INIT"
  pm2 restart strapi-develop
  sleep 10
  chown -R strapi:strapi /srv/strapi
fi