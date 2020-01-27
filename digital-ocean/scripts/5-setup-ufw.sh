#!/bin/bash -e

# enable ufw
echo "Enabling Uncomplicated Firewall (UFW)"
ufw --force enable

# reset UFW to defaults
echo "Resetting Defaults"
ufw default deny incoming
ufw default allow outgoing

# allow ssh, http, https
echo "Allow SSH, HTTP, and HTTPS"
ufw allow 22
ufw allow 80
ufw allow 443

# reload
echo "Reloading UFW"
ufw reload