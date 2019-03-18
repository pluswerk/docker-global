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
        startFunction pull
        startFunction build
        startFunction up
        return
        ;;
     up)
        docker-compose up -d
        return
        ;;
     stopOther)
        containers=$(docker ps --filter network=global -q)
        if [[ "$containers" ]]
        then
          docker stop $(printf "%s" "${containers}")
        fi
        return
        ;;
     down)
        startFunction stopOther
        docker-compose down --remove-orphans
        return
        ;;
     stop)
        startFunction stopOther
        docker-compose stop --remove-orphans
        return
        ;;
     *)
        docker-compose "${@:1}"
        return
        ;;
  esac
}

startFunction "${@:1}"
        exit $?
