#!/bin/bash

# this file is used to make it Possible from within wsl to update the hosts file of windows

is_wsl() {
  case "$(uname -r)" in
  *microsoft* ) true ;; # WSL 2
  *Microsoft* ) true ;; # WSL 1
  * ) false;;
  esac
}

if ! is_wsl; then
  echo 'not WSL skip'
  exit 1
fi

mkdir -p ~/www/global/.docker/data/windows-hosts-file/

syncHosts() {
  rsync -rtuv /mnt/c/Windows/System32/drivers/etc/hosts ~/www/global/.docker/data/windows-hosts-file/hosts
  rsync -rtuv ~/www/global/.docker/data/windows-hosts-file/hosts /mnt/c/Windows/System32/drivers/etc/hosts
  chmod -x ~/www/global/.docker/data/windows-hosts-file/hosts
}

while true
do
  syncHosts
  inotifywait -e modify -e move -e create -e delete --timeout 3600 /mnt/c/Windows/System32/drivers/etc/hosts ~/www/global/.docker/data/windows-hosts-file/hosts
done
