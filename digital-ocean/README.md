# Packer deployment for Digital-Ocean "One-Click" Deployment

This project is for generating Digital Ocean Images with a Strapi project behind an Nginx proxy. The main purpose is to generate one-click deployment options in the [Digital Ocean Marketplace](https://marketplace.digitalocean.com/) however anyone can use this to create your own custom images.

## How to use

The image creation system is using [Packer](https://www.packer.io/) by HashiCorp. You will need to install this for your local system. Simply download the package for your system and install it using the [documentation](https://www.packer.io/intro/getting-started/install.html#precompiled-binaries).

## Requirements

- A Digital Ocean [API key](https://cloud.digitalocean.com/account/api/tokens)
- A [SSH key](https://cloud.digitalocean.com/account/security) added to your Digital Ocean Account

## Instructions

1. Make a copy of the `example-variables.json` and set it as `variables.json`

2. Edit the `variables.json` to use your Digital Ocean API key

3. Use the following command to create the image: `packer build -var-file=variables.json template.json`

The packer script will do the following:

- Run Ubuntu System updates
- Add Node v12 LTS and Yarn repos (and install them)
- Add any required packages for Strapi
- Install Nginx and set it up to proxy Strapi on port 80
- Install [PM2](https://pm2.keymetrics.io/docs/usage/pm2-doc-single-page/) to run Strapi as a service
- Install the current LTS PostgreSQL database and setup a user/database
- Configure the Uncomplicated Firewall (UFW) (Ports 80, 443, and 22 are allowed by default)
- Clean the droplet of any logs and other misc files
- Validate the image for use with Digital Ocean
- Create the image on your own Digital Ocean account to be used for deploying