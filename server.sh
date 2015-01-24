#!/bin/bash

###############################################################################
#
# Simple script for starting, stopping, destroying, and generally handling
# docker commands.
#
###############################################################################

CWD=$(pwd)
MAPS_DIR=/opt/trinitycore/maps
CONF_DIR=/opt/trinitycore/conf

update-ip() {
  docker run --rm -it -e MYSQL_ROOT_PASSWORD=password -e USER_IP_ADDRESS="$1" trinitycore  update-ip
}

build() {
  case "$1" in
    -c | --core)
      echo "building core..."
      docker build -t trinitycore ./
      exit 0
      ;;
    -d | --database)
      echo "building database..."
      docker build -t trinitycore-db db/
      exit 0
      ;;
  esac

  echo "#"
  echo "# Building core..."
  echo "#"
  docker build -t trinitycore ./

  echo "#"
  echo "# Building database..."
  echo "#"
  docker build -t trinitycore-db db/

  # ask user for maps stuff? whether to use extractor or supply path?

  # ask for conf files? or use defaults?
  # if defaults, then need to specify datadir path AND IP address
  # need to run trinitycore update-up to setup realmlist

  # this directory gets mounted with trinitycore-db-maps, so any container that
  # uses --volumes-from trinitycore-db-maps will also get the conf files in the correct place

  # create containers
  echo "#"
  echo "# Creating containers..."
  echo "#"
  docker run -it --name trinitycore-db-maps -v ${CWD}/data/conf:${CONF_DIR} -v ${CWD}/data/maps:${MAPS_DIR} -it trinitycore data
  docker run -it --name trinitycore-db-mysql -it trinitycore-db data
  docker run -it --name trinitycore-db-server --volumes-from trinitycore-db-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password trinitycore-db mysqld

  # stop server to allow for more commands to be input?
  #docker stop trinitycore-db-server

  # this should be run as soon as possible...with the correct ip address...once the mysqld is ready.
}

start_server() {
  case "$1" in
    -s | --server)
      case "$2" in
        auth)
          echo "#"
          echo "# Starting auth server..."
          echo "#"
          docker run --rm -it --volumes-from trinitycore-db-maps trinitycore authserver
          exit 0
          ;;
        extractor)
          echo "#"
          echo "# ENGAGE EXTRACTORS!"
          echo "#"
          read -p "path to warcraft 3.3.5a client? " wow_path
          docker run --rm -it --volumes-from trinitycore-db-maps -v ${wow_path}:/opt/wow-client trinitycore extract-maps
          exit 0
          ;;
        world)
          echo "#"
          echo "# Starting world server..."
          echo "#"
          docker run --rm -it --volumes-from trinitycore-db-maps trinitycore worldserver
          exit 0
          ;;
        db)
          echo "#"
          echo "# Starting db server..."
          echo "#"
          docker start trinitycore-db-server
          exit 0
          ;;
      esac
      ;;
  esac

  echo "#"
  echo "# Spooling up all servers..."
  echo "#"

  # start mysld
  docker start trinitycore-db-server

  # start worldserver
  # conf files should be in $(pwd)
  docker run --name worldserver --rm -d --volumes-from trinitycore-db-maps trinitycore worldserver
  docker run --name authserver --rm -d --volumes-from trinitycore-db-maps trinitycore authserver

}

stop_server() {
  case "$1" in
    -d | --docker)
      echo "stopping docker containers..."
      docker stop trinitycore-db-server
      exit 0
      ;;
    -s | --server)
      case "$2" in
        auth)
          echo "stopping auth server..."
          exit 0
          ;;
        world)
          echo "stopping world server..."
          exit 0
          ;;
        db)
          echo "stopping db server..."
          exit 0
          ;;
      esac
      ;;
  esac

  echo "stopping all warcraft servers..."
}

destroy() {
  case "$1" in
     --everything)
      echo "Destroying all images and containers!"
      docker rm $(docker ps -a -q)
      docker rmi $(docker images -q)
      exit 0
      ;;
    --containers)
      echo "Destroying all containers.."
      docker rm $(docker ps -a -q)
      exit 0
      ;;
    --images)
      echo "Destroying all images..."
      docker rmi $(docker images -q)
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "See ./server.sh help for usage"
      exit 1
  esac
}

help() {
  case "$1" in
    -d | --docker)
    docker run --rm -it trinitycore help
    exit 0
  esac

  echo ""
  echo "Help for the server helper script!"
  echo ""
  echo "USAGE:"
  echo "  ./server.sh <command> [options]"
  echo ""
  echo "COMMANDS:"
  echo ""
  echo "  build [-a | -c | -d]"
  echo "      Build stuff with docker! Using no options or -a will build the"
  echo "      TrinityCore main image and the TrinityCore database image."
  echo ""
  echo "      The images will have default names tied to them."
  echo ""
  echo "  destroy --everything | --images | --containers"
  echo "      This is extremely volitile! Destroys images to free up space"
  echo "      for rebuilding and having a nice clean fresh start feeling."
  echo ""
  echo "      Because this command deletes stuff, you must set options."
  echo "      Running this command by itself will error."
  echo ""
  echo "  help [-d]"
  echo "      Display this help message. Or, if the -d options is set, display"
  echo "      the help message for docker entrypoint commands."
  echo ""
  echo "  start [-a | -s <auth|world|db>]"
  echo "      Starts servers. If no options or -a is specified, this will start"
  echo "      all servers. If -s is set, then only the server corresponding to"
  echo "      <auth|world|db> will be started."
  echo ""
  echo "  stop [-a | -s <auth|world|db>]"
  echo "      Stops servers. If no options or -a is specified, this will stop"
  echo "      all servers. If -s is set, then only the server corresponding to"
  echo "      <auth|world|db> will be stopped."
  echo ""
  echo "END OF HELP good night"
  exit 0
}

# Main entrypoint
case "$1" in
  build)
    shift
    build $@
    ;;
  update-ip)
    shift
    update-ip $@
    ;;
  destroy)
    shift
    destroy $@
    ;;
  help | -h | --help)
    shift
    help $@
    ;;
  start)
    shift
    start_server $@
    ;;
  stop)
    shift
    stop_server $@
  ;;
  *)
    shift
    help $@
    ;;
esac
