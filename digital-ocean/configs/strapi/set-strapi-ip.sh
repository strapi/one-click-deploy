#!/bin/bash

# Used to set Strapi proxy IP on first boot, you can safely delete this script
SERVER=/srv/strapi/strapi/config/environments/development/server.json
INIT=/srv/strapi/ip-init
IP=$(curl -s ifconfig.me)

if [ -f "$INIT" ]; then
  sed -i "s/changeme/$IP/g" "$SERVER"
  rm "$INIT"
  pm2 restart strapi-develop
fi