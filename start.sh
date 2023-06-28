#!/bin/bash

. .env

mkdir -p ./.docker/data/global-xhgui
sudo chmod -R 777 ./.docker/data/global-xhgui
sudo chmod -R 777 ./mysql_native_password.sql

if [ -z "$TLD_DOMAIN" ]; then
  export TLD_DOMAIN=vm${VM_NUMBER}.iveins.de
fi

export SUBDOMAIN=$(echo $TLD_DOMAIN | cut -d. -f1)
export ZONE=$(echo $TLD_DOMAIN | cut -d. -f2-3)

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
        docker-compose up -d --remove-orphans
        ;;
     down)
        docker-compose down --remove-orphans
        ;;
     stop)
        docker-compose stop --remove-orphans
        ;;
     *)
        docker-compose "${@:1}"
        ;;
  esac
}

docker network inspect global &>/dev/null || docker network create global
startFunction "${@:1}"
        exit $?
