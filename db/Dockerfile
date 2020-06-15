FROM mariadb:latest

ENV DEBIAN_FRONTEND noninteractive
ENV SQL_DIR /etc/db/sql
ENV TC_DB_SQL https://raw.githubusercontent.com/TrinityCore/TrinityCore/3.3.5/sql/create/create_mysql.sql

RUN apt-get update && \
  apt-get install -y \
  wget

RUN mkdir -p $SQL_DIR && \
    cd $SQL_DIR && \
    wget $TC_DB_SQL

ADD gift-bag.sql /etc/db/sql/gift-bag.sql