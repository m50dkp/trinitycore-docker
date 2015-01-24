#!/bin/bash

CMD="${1%_safe}"

if [ "$CMD" = 'data' ]
then

  echo 'Built data only container'

elif [ "$CMD" = 'extract-maps' ]
then

  echo 'Extracting maps from /opt/wow-client into /opt/tc/maps'
  /etc/extract_maps.sh

elif [ "$CMD" = 'worldserver' ]
then

  echo 'Starting world server...'
  
  # check to see if the worldserver conf is specified.
  # if not, copy in the default and change the ip address
  # and the data dir for the vmaps and such
  if [ ! -f '/opt/tc/conf/worldserver.conf' ]; then

    echo "using default worldserver conf file"

    # copy installed via TrinityCore repo
    cp /usr/local/etc/worldserver.conf.dist /opt/tc/conf/worldserver.conf

  fi

  if [ -z "$TCDB_PORT_3306_TCP_ADDR" ]; then
    echo "Could not find linked database container. Was one linked with an alias of TCDB?"
    exit 1
  fi

  # use the linked 
  sed -i "s/LoginDatabaseInfo.*$/LoginDatabaseInfo = \"$TCDB_PORT_3306_TCP_ADDR;$TCDB_PORT_3306_TCP_PORT;trinity;trinity;auth\"/" /opt/tc/conf/worldserver.conf
  sed -i "s/WorldDatabaseInfo.*$/WorldDatabaseInfo = \"$TCDB_PORT_3306_TCP_ADDR;$TCDB_PORT_3306_TCP_PORT;trinity;trinity;world\"/" /opt/tc/conf/worldserver.conf
  sed -i "s/CharacterDatabaseInfo.*$/CharacterDatabaseInfo = \"$TCDB_PORT_3306_TCP_ADDR;$TCDB_PORT_3306_TCP_PORT;trinity;trinity;characters\"/" /opt/tc/conf/worldserver.conf
  sed -i "s%DataDir.*$%DataDir = \"/opt/tc/maps\"%" /opt/tc/conf/worldserver.conf

  # RUN. IT.
  /usr/local/bin/worldserver -c /opt/tc/conf/worldserver.conf

elif [ "$CMD" = 'authserver' ]
then

  echo 'Starting auth server...'
  
  # check to see if the authserver conf is specified.
  # if not, copy in the default and change the ip address
  if [ ! -f '/opt/tc/conf/authserver.conf' ]; then
    echo "using default auth conf file"

    # copy installed via TrinityCore repo
    cp /usr/local/etc/authserver.conf.dist /opt/tc/conf/authserver.conf

  fi

  if [ -z "$TCDB_PORT_3306_TCP_ADDR" ]; then
    echo "Could not find linked database container. Was one linked with an alias of TCDB?"
    exit 1
  fi

  # update the config file with the linked db container address/port
  sed -i "s/LoginDatabaseInfo.*$/LoginDatabaseInfo = \"$TCDB_PORT_3306_TCP_ADDR;$TCDB_PORT_3306_TCP_PORT;trinity;trinity;auth\"/" /opt/tc/conf/authserver.conf

  # RUN. IT.
  /usr/local/bin/authserver -c /opt/tc/conf/authserver.conf

elif [ "$CMD" = 'help' ]
then
  echo ""
  echo 'Displaying help for using docker with TrinityCore. I have no clue if'
  echo 'this is how these commands should be run, but hey. Now we have some'
  echo 'help text to copy to a real home.'
  echo ""
  echo 'SYNOPSIS'
  echo '  docker run --rm -e <ENVIRONMENT_VARS> <containerid> <command>'
  echo ""
  echo 'COMMANDS'
  echo '  authserver'
  echo '      Start the authserver. If you do not mount an authserver.conf file,' 
  echo '      the default will be used with corresponding ip address given by '
  echo '      the environment variable USER_IP_ADDRESS'
  echo ""
  echo '      USER_IP_ADDRESS is the ip address of the computer you are running the'
  echo '      warcraft server on. Specify a public ip if you want others outside'
  echo '      of your local network to connect to your server. This must be the'
  echo '      same as the worldserver ip address.'
  echo ""
  echo '  data'
  echo '      Build container to be used as a data container'
  echo ""
  echo '  extract-maps'
  echo '      Runs a script to extract maps, mmaps, vmaps, and dbc from the'
  echo '      client. The script assumes that the client is version 3.3.5a'
  echo '      and that the client is mounted at point /opt/wow-client/'
  echo ""
  echo '  help'
  echo '      Displays this help command. But I guess runs this container'
  echo '      as well? hmm..something is weird here...maybe this isnt how this is '
  echo '      supposed to work...'
  echo ""
  echo '  update-ip'
  echo '      Update the ip address of the worldserver and authserver by'
  echo '      specifying the environment variable USER_IP_ADDRESS.'
  echo '      Specify a public ip address if you want others outside'
  echo '      of your local network to connect to your server.'
  echo '      You must also specify the environment variable'
  echo '      MYSQL_ROOT_PASSWORD'
  echo ""
  echo '  worldserver'
  echo '      Start the worldserver. If you do not mount a worldserver.conf file,'
  echo '      the default will be used. If you plan on using the default configuration'
  echo '      you must specify both environment variables USER_IP_ADDRESS and'
  echo '      USER_DATA_DIR'
  echo ""
  echo '      USER_IP_ADDRESS is the ip address of the computer you are running'
  echo '      the warcraft server on. Specify a public ip if you want others outside'
  echo '      of your local network to connect to your server. This must be the'
  echo '      same as the authserver ip address.'
  echo ""
  echo '      USER_DATA_DIR is the path to the folder containing the maps, mmaps, vmaps,'
  echo '      and dbc needed to run the worldserver.'
  echo ""
  echo 'END OF HELP good night'

elif [ "$CMD" = 'update-ip' ]
then

    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
      echo >&2 'error: MYSQL_ROOT_PASSWORD env var required'
      exit 1
    fi

    if [ -z "$TCDB_PORT_3306_TCP_ADDR" ]; then
      echo "Could not find linked database container. Was one linked with an alias of TCDB?"
      exit 1
    fi

    if [ -z "$USER_IP_ADDRESS" ]; then
      echo >&2 'error: USER_IP_ADDRESS env var required'
      exit 1
    fi

    # TODO: is there a way to do this without using a heredoc?
    mysql -h"$TCDB_PORT_3306_TCP_ADDR" -uroot -p"$MYSQL_ROOT_PASSWORD" <<-GrantDoc
    GRANT ALL PRIVILEGES ON world . * TO 'trinity'@'%' IDENTIFIED BY 'trinity' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON characters . * TO 'trinity'@'%' IDENTIFIED BY 'trinity' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON auth . * TO 'trinity'@'%' IDENTIFIED BY 'trinity' WITH GRANT OPTION;
    use auth;
    UPDATE realmlist set address='${USER_IP_ADDRESS}', localAddress='${USER_IP_ADDRESS}' WHERE name='Trinity';
    FLUSH PRIVILEGES;
GrantDoc

else

  exec "$@"

fi