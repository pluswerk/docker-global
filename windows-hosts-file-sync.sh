#!/bin/bash

# this file is used to make it Possible from within wsl to update the hosts file of windows

if ! is_wsl; then
  echo 'not WSL skip'
  exit 1
fi

if ps -aux | grep '[w]indows-hosts-file-sync.sh' >&/dev/null ; then
  echo 'already running'
  exit 1
fi

mkdir -p ~/www/global/.docker/data/windows-hosts-file/
while sleep 0.5
do
  rsync -rtuv /mnt/c/Windows/System32/drivers/etc/hosts ~/www/global/.docker/data/windows-hosts-file/hosts
  rsync -rtuv ~/www/global/.docker/data/windows-hosts-file/hosts /mnt/c/Windows/System32/drivers/etc/hosts
  chmod -x ~/www/global/.docker/data/windows-hosts-file/hosts
done
