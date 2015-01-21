export SQL="$TC_DIR/TrinityCore/sql"

cat $SQL/create/create_mysql.sql | mysql -hmysql -P3306 -uroot -pGreatBeyond
cat $SQL/base/auth_database.sql | mysql -hmysql -P3306 -uroot -pGreatBeyond -Dauth
cat $SQL/base/characters_database.sql | mysql -hmysql -P3306 -uroot -pGreatBeyond -Dcharacters

cat $TC_DIR/sql/TDB_full_*.sql | mysql -hmysql -P3306 -uroot -pGreatBeyond -Dworld

for file in $SQL/updates/world/*.sql; do
  cat $file | mysql -hmysql -P3306 -uroot -pGreatBeyond -Dworld
done
