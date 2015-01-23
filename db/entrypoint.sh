#!/bin/bash

CMD="${1%_safe}"

if [ "$CMD" = 'data' ]
then

  echo 'Built data only container'

elif [ "$CMD" = 'mysqld' ]
then

  if [ ! -d '/var/lib/mysql/world' ]
  then

    # TODO: we're just checking for world...need a better way for
    # detecting if the data is there or not.
    # TODO: check for TCDB revision? I think it's actually in the db somewhere.
    # TODO: found it: use world; select `db_version` from `version` LIMIT 1;
    # but mysqld needs to be running, so maybe not viable.

    echo 'No TrinityCore data detected. Initializing database...'
    /etc/db/install.sh

  fi

  echo 'Starting mysqld...'

  # docker-entrypoint.sh comes from mariadb
  /docker-entrypoint.sh mysqld_safe

else

  exec "$@"

fi
