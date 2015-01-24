#!/bin/bash

# example:
# $ ./server-simple.sh /Users/drew/Desktop/WoW/ServerData/ $(boot2docker ip)
#
# To attach to the worldserver interactively:
# $ docker attach --sig-proxy=false trinitycore-worldserver
#
# To delete the servers to regenerate things:
# $ docker rm -f trinitycore-dbserver trinitycore-authserver trinitycore-worldserver
#
# To start from scratch (!):
# docker rm -f trinitycore-maps trinitycore-db-mysql trinitycore-dbserver trinitycore-authserver trinitycore-worldserver
# 
# REMEMBER TO FORWARD PORTS (3724,8085) FROM THE VM (via virtualbox) to your local machine if you want others to join

DATA_DIR=$1
PUBLIC_IP=$2

# build
docker build -t trinitycore ./
docker build -t trinitycore-db ./db

# create data containers
docker create -it --name trinitycore-maps -v ${DATA_DIR}/conf:/opt/tc/conf -v ${DATA_DIR}/maps:/opt/tc/maps trinitycore data
docker create -it --name trinitycore-db-mysql -it trinitycore-db data

# start servers
docker run --name trinitycore-dbserver -d -e MYSQL_ROOT_PASSWORD=password --volumes-from trinitycore-db-mysql trinitycore-db mysqld

# TODO: need a way to wait for mysql to finish initializing if first time... the rest of these will fail otherwise.
docker run --rm -it --link trinitycore-dbserver:TCDB trinitycore mysqladmin --wait=30 -hTCDB -uroot -ppassword ping

docker run --name trinitycore-authserver -ti -d --link trinitycore-dbserver:TCDB -p 3724:3724 --volumes-from trinitycore-maps trinitycore authserver
docker run --name trinitycore-worldserver -i -d --link trinitycore-dbserver:TCDB -p 8085:8085 --volumes-from trinitycore-maps trinitycore worldserver

# update realmlist / grant tables to point at the "public" IP (or at least accessible for other people within the same LAN)
docker run --rm -it --link trinitycore-dbserver:TCDB -e MYSQL_ROOT_PASSWORD=password -e USER_IP_ADDRESS="$PUBLIC_IP" trinitycore update-ip

# example of connecting to the mysql server via another container for admin purposes:
# docker run --rm --link trinitycore-dbserver:TCDB trinitycore mysql -hTCDB -utrinity -ptrinity -e 'select 1;'

# ctrl+c gracefully kills things
#trap control_c SIGINT
