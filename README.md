# Docker-Global

Docker Global Setup makes it much easier to develop websites. This bundles the most important services into a single package using [Docker](https://docker.com).

The individual websites then still need the [pluswerk/php-dev](https://github.com/pluswerk/php-dev) package and that's all.

This setup is extensible and well customizable for the individual needs of a project.

## Requirements

You need [Docker](https://docker.com) and a few free ports, depending on whether you want to customize it even further.

* [Docker](https://docker.com)
* Free Ports: 80, 443, 1025, 3306

## Setup steps

Before you start the setup you need to stop all processes what block ports 80, 443, 1025, 3306.

````bash
git clone git@github.com:pluswerk/docker-global.git global
cd global
# always start it with this command(if it is not running already):
bash start.sh start
````

## .env file | Customize

You can create a .env file and overwrite some Settings:

````bash
# restart global containers? https://docs.docker.com/compose/compose-file/#restart
RESTART=always
# host ports: You can change the ports without breaking php-dev installations. (maybe if you change 80 or 443)
HTTP_PORT=80
HTTPS_PORT=443
DB_PORT=3306
SMTP_PORT=1025

# Overwrite global-mail or global-portainer domain
MAIL_VIRTUAL_HOST=~^mail\.(vm|vm\d+\.iveins\.de)$$
PORTAINER_VIRTUAL_HOST=~^portainer\.(vm|vm\d+\.iveins\.de)$$
````

## further Documentation

See the [Documentation](docs/index.md) of this Setup System.
