#!/bin/bash

CMD="${1%_safe}"

if [ "$CMD" = 'data' ]
then

  echo 'Built data only container'

elif [ "$CMD" = 'extract-maps' ]
then

  echo 'Extracting maps from /opt/wow-client into /opt/trinitycore-data'
  /etc/extract_maps.sh

elif [ "$CMD" = 'worldserver' ]
then

  echo 'Starting world server...'
  
  # check to see if the worldserver conf is specified.
  # if not, copy in the default and change the ip address
  # and the data dir for the vmaps and such
  if [ ! -a '/opt/trinitycore-data/worldserver.conf']; then
    echo "using default worldserver conf file"

    # copy installed via TrinityCore repo
    cp /usr/local/etc/worldserver.conf.dist /opt/trinitycore-data/worldserver.conf

    # set the user given ip address for the database
    # and set the user given data dir? base info needed to go!
    sed -i '' "s/LoginDatabaseInfo.*$/LoginDatabaseInfo = \"$USER_IP_ADDRESS;3306;trinity;trinity;auth\"/" /opt/trinitycore-data/worldserver.conf
    sed -i '' "s/WorldDatabaseInfo.*$/WorldDatabaseInfo = \"$USER_IP_ADDRESS;3306;trinity;trinity;world\"/" /opt/trinitycore-data/worldserver.conf
    sed -i '' "s/CharacterDatabaseInfo.*$/CharacterDatabaseInfo = \"$USER_IP_ADDRESS;3306;trinity;trinity;characters\"/" /opt/trinitycore-data/worldserver.conf
    sed -i '' "s/DataDir.*/DataDir = \"$USER_DATA_DIR\"/" /opt/trinitycore-data/worldserver.conf
  fi

  # RUN. IT.
  /usr/local/bin/worldserver -c /opt/trinitycore-data/worldserver.conf

elif [ "$CMD" = 'authserver' ]
then

  echo 'Starting auth server...'
  
  # check to see if the authserver conf is specified.
  # if not, copy in the default and change the ip address
  if [ ! -a '/opt/trinitycore-data/authserver.conf']; then
    echo "using default auth conf file"

    # copy installed via TrinityCore repo
    cp /usr/local/etc/authserver.conf.dist /opt/trinitycore-data/confs/authserver.conf

    # set the user given ip address for the database
    sed -i '' "s/LoginDatabaseInfo.*$/LoginDatabaseInfo = \"$USER_IP_ADDRESS;3306;trinity;trinity;auth\"/" /opt/trinitycore-data/authserver.conf

  fi

  # RUN. IT.
  /usr/local/bin/authserver -c /opt/trinitycore-data/authserver.conf

else

  exec "$@"

fi
