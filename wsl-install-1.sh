#!/bin/bash
set -e

if [ ! $(getent group docker) ]; then
  # create docker group
  sudo groupadd docker
fi

if [ $(id -gn) != docker ]; then
  # add docker group to user
  sudo usermod -aG docker $USER
  # restart script with docker group:
  echo 'You must restart the Terminal!!!'
  exit 0
fi

echo 'Now you can run wsl-install-2.sh'
