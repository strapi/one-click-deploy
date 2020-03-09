#!/bin/bash -e

# install PostgreSQL
echo "Installing PostgreSQL"
apt-get install -y -q postgresql postgresql-contrib > /dev/null

# generate new database password and dump to a temp file for strapi install
echo "Generating a random password"
PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
echo "$PASS" > /srv/strapi/temp_pgpass

# create strapi user in pg
echo "Creating the Strapi DB User"
su - postgres -c "createuser strapi > /dev/null" 

# create strapi database in pg
echo "Creating the Strapi DB Database"
su - postgres -c "createdb strapi > /dev/null"

# setting strapi password and permissons
echo "Granting the Strapi user permissions to the database"
su - postgres -c "psql -c \"alter user strapi with encrypted password '$PASS';\""
su - postgres -c "psql -c \"grant all privileges on database strapi to strapi;\""