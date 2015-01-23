#!/bin/bash

# a docker entrypoint script for initializing the database if no data
# exists, and starting the mysql server.

TC_DIR='/usr/local/trinitycore'
TC_REPO='git://github.com/TrinityCore/TrinityCore.git'
TC_DB_URL='https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.57/TDB_full_335.57_2014_10_19.7z'

SQL="$TC_DIR/TrinityCore/sql"

mkdir -p $TC_DIR
cd $TC_DIR
git clone -b 3.3.5 --depth 1 $TC_REPO

echo 'Downloading latest TrinityCore Database...'
mkdir -p $TC_DIR/sql
cd $TC_DIR/sql
wget $TC_DB_URL
7z x *.7z

/docker-entrypoint.sh mysqld_safe &

mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" --silent --wait=30 ping

echo 'Creating tables...'
cat $SQL/create/create_mysql.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD"
echo 'Creating auth...'
cat $SQL/base/auth_database.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dauth
echo 'Creating characters...'
cat $SQL/base/characters_database.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dcharacters
echo 'Creating world...'
cat $TC_DIR/sql/TDB_full_*.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dworld

echo 'Applying updates...'
for file in $SQL/updates/world/*.sql; do
    cat $file | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dworld
done

mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" --silent --wait=30 shutdown
rm -rf $TC_DIR
chown -R mysql:mysql /var/lib/mysql

echo 'Finished initializing database'
