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
  # TODO: use the user mounted one if it exists, else use the default
  #/usr/local/bin/worldserver -c /opt/trinitycore-data/worldserver.conf

elif [ "$CMD" = 'authserver' ]
then

  echo 'Starting auth server...'
  # TODO: use the user mounted one if it exists, else use the default
  #/usr/local/bin/authserver -c /opt/trinitycore-data/authserver.conf

else

  exec "$@"

fi
