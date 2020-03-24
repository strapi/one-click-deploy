#!/bin/bash -e

sudo rm -rf /tmp/* /var/tmp/* /srv/strapi/.pm2/logs/* /var/log/ufw.log
history -c
unset HISTFILE

sudo apt-get -y autoremove
sudo apt-get -y autoclean

sudo find /var/log -mtime -1 -type f -exec truncate -s 0 {} \;
sudo rm -rf /var/log/*.gz /var/log/*.[0-9] /var/log/*-???????? /var/log/*.log
sudo rm -rf /var/lib/cloud/instances/*
sudo rm -rf /var/lib/cloud/instance
sudo rm -f /root/.ssh/authorized_keys /etc/ssh/*key*
sudo touch /etc/ssh/revoked_keys
sudo chmod 600 /etc/ssh/revoked_keys

# Securely erase the unused portion of the filesystem
GREEN='\033[0;32m'
NC='\033[0m'
printf "\n${GREEN}Writing zeros to the remaining disk space to securely
erase the unused portion of the file system.
Depending on your disk size this may take several minutes.
The secure erase will complete successfully when you see:${NC}
    dd: writing to '/zerofile': No space left on device\n
Beginning secure erase now\n"

sudo dd if=/dev/zero of=/zerofile &
  PID=$!
  while [ -d /proc/$PID ]
    do
      printf "."
      sleep 5
    done
sync; sudo rm /zerofile; sync