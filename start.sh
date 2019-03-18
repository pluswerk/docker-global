#!/bin/bash

function startFunction {
  key="$1"
  case ${key} in
     upgrade)
        git fetch && git checkout master && git pull
        ;;
     start)
        startFunction pull
        startFunction build
        startFunction up
        ;;
     up)
        docker-compose up -d
        ;;
     stopOther)
        containers=$(docker ps --filter network=global -q)
        if [[ "$containers" ]]; then
          docker stop $(printf "%s" "${containers}")
        fi
        ;;
     down)
        startFunction stopOther
        docker-compose down --remove-orphans
        ;;
     stop)
        startFunction stopOther
        docker-compose stop --remove-orphans
        ;;
     *)
        docker-compose "${@:1}"
        ;;
  esac
}

startFunction "${@:1}"
        exit $?
