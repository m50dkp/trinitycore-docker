#!/bin/bash

# example:
# $ ./server-simple.sh /Users/drew/Desktop/WoW/ServerData/ $(boot2docker ip)
#
# To attach to the worldserver interactively:
# $ docker attach --sig-proxy=false tc-worldserver
#
# To delete the servers to regenerate things:
# $ docker rm -f tc-dbserver tc-authserver tc-worldserver
#
# To start from scratch (!):
# $ docker rm -f tc-maps tc-mysql-data tc-dbserver tc-authserver tc-worldserver
#
# example of connecting to the mysql server via another container for admin purposes:
# $ docker run --rm --link tc-dbserver:TCDB trinitycore mysql -hTCDB -utrinity -ptrinity -e 'select 1;'
#
# REMEMBER TO FORWARD PORTS (3724,8085) FROM THE VM (via virtualbox) to your local machine if you want others to join

# TODO: include map extraction, etc...


DATA_DIR=$1
PUBLIC_IP=$2
EXTRACT_MAPS_USING_CLIENT_DIR=$3

MAPS_DIR=/opt/trinitycore/maps
CONF_DIR=/opt/trinitycore/conf

# build
docker build -t trinitycore ./
docker build -t trinitycore-db ./db

if [ ! -z "$EXTRACT_MAPS_USING_CLIENT_DIR" ]; then
  docker run --name map-container -it -v ${EXTRACT_MAPS_USING_CLIENT_DIR}:/opt/wow-client trinitycore extract-maps
  docker commit map-container trinitycore-maps
  docker rm map-container
  docker create -it --name tc-maps trinitycore-maps data
fi

# create database data container
docker create -it --name tc-mysql-data -it trinitycore-db data

# init server
docker run --rm -ti --volumes-from tc-mysql-data -e MYSQL_ROOT_PASSWORD=password trinitycore-db init

# start db
docker run --name tc-dbserver -d -ti --volumes-from tc-mysql-data -e MYSQL_ROOT_PASSWORD=password trinitycore-db mysqld

# wait for mysql
docker run --rm -it --link tc-dbserver:TCDB trinitycore mysqladmin --wait=30 -hTCDB -uroot -ppassword ping

# update realmlist / grant tables to point at the "public" IP (or at least accessible for other people within the same LAN)
docker run --rm -it --link tc-dbserver:TCDB -e MYSQL_ROOT_PASSWORD=password -e USER_IP_ADDRESS="$PUBLIC_IP" trinitycore update-ip

# start the world/auth
docker run --name tc-authserver -ti -d --link tc-dbserver:TCDB -p 3724:3724 trinitycore authserver
docker run --name tc-worldserver -i -d --link tc-dbserver:TCDB -p 8085:8085 --volumes-from tc-maps trinitycore worldserver

# ctrl+c gracefully kills things
#trap control_c SIGINT
