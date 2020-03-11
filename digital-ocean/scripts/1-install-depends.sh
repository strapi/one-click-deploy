#!/bin/bash -e

# Stop generating errors for non-interactive shell
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

# perform standard ubuntu updates
echo "Doing updates to system"
apt-get update -q > /dev/null
apt-get upgrade -y -q > /dev/null
apt-get dist-upgrade -y -q > /dev/null
apt-get autoremove -y -q > /dev/null

# add 3rd party repos
echo "Adding Node.js and Yarn repos"
## node
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - > /dev/null
## yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null

# install required packages for strapi
echo "Installing Strapi package depends"
apt-get update -q > /dev/null
apt-get install -y -q nodejs yarn build-essential libpng-dev node-gyp > /dev/null

# install nginx
echo "Installing Nginx"
apt-get install -y -q nginx > /dev/null
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original
mv /tmp/nginx/nginx.conf.new /etc/nginx/nginx.conf
systemctl -q enable nginx
systemctl -q restart nginx

# add pm2 globally
echo "Setting up PM2"
yarn global add pm2 > /dev/null

# install PostgreSQL
echo "Installing PostgreSQL"
apt-get install -y -q postgresql postgresql-contrib > /dev/null