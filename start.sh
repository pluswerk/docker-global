#!/bin/bash

. .env

mkdir -p ./.docker/data/global-xhgui
mkdir -p ./.docker/data/global-nginx-proxy/
if [ -d ./.docker/data/global-nginx-proxy/searchforcompose.conf ]; then
    sudo rm -r ./.docker/data/global-nginx-proxy/searchforcompose.conf
fi
sudo touch ./.docker/data/global-nginx-proxy/searchforcompose.conf
sudo chmod -R 777 ./.docker/data/global-nginx-proxy/searchforcompose.conf
sudo chmod -R 777 ./.docker/data/global-xhgui
sudo chmod -R 777 ./mysql_native_password.sql

if [ -z "$TLD_DOMAIN" ]; then
  export TLD_DOMAIN=vm${VM_NUMBER}.iveins.de
fi
if [ -z "$VM_NUMBER" ]; then
  export VM_NUMBER=$(echo $TLD_DOMAIN | cut -d. -f1 | cut -dm -f2)
fi

if [ -z "$SUBDOMAIN" ]; then
  export SUBDOMAIN=$(echo $TLD_DOMAIN | cut -d. -f1)
fi
if [ -z "$ZONE" ]; then
  export ZONE=$(echo $TLD_DOMAIN | cut -d. -f2-3)
fi

function startFunction {
  key="$1"
  case ${key} in
     upgrade)
        git fetch && git checkout master && git pull
        ;;
     start)
        startFunction upgrade && \
        startFunction pull && \
        startFunction build && \
        startFunction up
        ;;
     up)
        docker-compose up -d --remove-orphans --wait
        ;;
     down)
        docker-compose down --remove-orphans
        ;;
     stop)
        docker-compose stop
        ;;
     *)
        docker-compose "${@:1}"
        ;;
  esac
}

docker network inspect global &>/dev/null || docker network create global
startFunction "${@:1}"
        exit $?
