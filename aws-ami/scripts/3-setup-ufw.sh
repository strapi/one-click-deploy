#!/bin/bash -e

# enable ufw
echo "Enabling Uncomplicated Firewall (UFW)"
sudo ufw --force enable

# reset UFW to defaults
echo "Resetting Defaults"
sudo ufw default deny incoming
sudo ufw default allow outgoing

# allow ssh, http, https
echo "Allow SSH, HTTP, and HTTPS"
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

# reload
echo "Reloading UFW"
sudo ufw reload