#!/bin/bash

CMD="${1%_safe}"

if [ "$CMD" = 'data' ]
then

  echo 'Built data only container'

elif [ "$CMD" = 'mysqld' ]
then

  # check for data
  if [ ! -d '/var/lib/mysql/world' ]
  then

    echo "No TrinityCore data detected. Please run 'init' first."

  else
    echo 'Starting mysqld...'

    # docker-entrypoint.sh comes from mariadb
    /docker-entrypoint.sh mysqld_safe
  fi

elif [ "$CMD" = 'init' ]
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
  

else

  exec "$@"

fi
