#!/bin/bash

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
        docker-compose up -d
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
