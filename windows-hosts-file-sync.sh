#!/bin/bash

# this file is used to make it Possible from within wsl to update the hosts file of windows

mkdir -p ~/www/global/.docker/data/windows-hosts-file/

while sleep 0.5
do
  rsync -rtuv /mnt/c/Windows/System32/drivers/etc/hosts ~/www/global/.docker/data/windows-hosts-file/hosts
  rsync -rtuv ~/www/global/.docker/data/windows-hosts-file/hosts /mnt/c/Windows/System32/drivers/etc/hosts
  chmod -x ~/www/global/.docker/data/windows-hosts-file/hosts
done
