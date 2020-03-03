#!/bin/bash -e

# Stop generating errors for non-interactive shell
export DEBIAN_FRONTEND=noninteractive

# perform standard ubuntu updates
echo "Doing updates to system"
sudo apt-get update -q > /dev/null
sudo apt-get upgrade -y -q > /dev/null
sudo apt-get dist-upgrade -y -q > /dev/null
sudo apt-get autoremove -y -q > /dev/null

# add 3rd party repos
echo "Adding Node.js and Yarn repos"
## node
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - > /dev/null
## yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null

# install required packages for strapi
echo "Installing Strapi package depends"
sudo apt-get update -q > /dev/null
sudo apt-get install -y -q nodejs yarn build-essential libpng-dev node-gyp > /dev/null

# install nginx
echo "Installing Nginx"
sudo apt-get install -y -q nginx > /dev/null
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original
sudo mv /tmp/nginx/nginx.conf.new /etc/nginx/nginx.conf
sudo systemctl -q enable nginx
sudo systemctl -q restart nginx

# add pm2 globally
echo "Setting up PM2"
sudo yarn global add pm2 > /dev/null