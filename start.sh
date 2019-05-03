#!/bin/bash

function startFunction {
  key="$1"
  echo "running script ${key}"
  case ${key} in
     upgrade)
        git fetch && git checkout master && git pull
        return
        ;;
     start)
        startFunction upgrade && \
        startFunction pull && \
        startFunction build && \
        startFunction up
        return
        ;;
     up)
        docker-compose up -d
        return
        ;;
     down)
        docker-compose down --remove-orphans
        return
        ;;
     stop)
        docker-compose stop --remove-orphans
        return
        ;;
     *)
        docker-compose "${@:1}"
        return
        ;;
  esac
}

docker network inspect global &>/dev/null || docker network create global
startFunction "${@:1}"
        exit $?
