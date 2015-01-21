export SQL="$TC_DIR/TrinityCore/sql"
export MYSQL_ROOT_PASSWORD="password"

# start mysqld in the background
/docker-entrypoint.sh mysqld_safe &

# we need to wait for that to complete
mysqladmin --silent --wait=30 ping || exit 1

# now initialize
cat $SQL/create/create_mysql.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD"

cat $SQL/base/auth_database.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dauth

cat $SQL/base/characters_database.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dcharacters

cat $TC_DIR/sql/TDB_full_*.sql | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dworld

for file in $SQL/updates/world/*.sql; do
  cat $file | mysql -h"localhost" -P"3306" -uroot -p"$MYSQL_ROOT_PASSWORD" -Dworld
done

# TODO: not sure if we need to do the chmods...
