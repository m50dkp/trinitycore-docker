#!/bin/bash

set -e

# It is expected that /opt/wow-client and /opt/trinitycore-data are provided
# via a mounted volume (-v) as part of `docker run`.

DIRS=(dbc maps mmaps vmaps Buildings)
BIN=/usr/local/trinitycore/bin

cd $CLIENT_DIR

# kill existings directories if they exist
for d in ${DIRS[@]}
do
  if [ -d "$d" ]
  then
    echo "Removing directory $d"
    rm -r "$d"
  fi
done

# dbc, maps
$BIN/mapextractor -f 0

# vmaps
$BIN/vmap4extractor
mkdir vmaps
$BIN/vmap4assembler Buildings vmaps

# mmaps
mkdir mmaps
$BIN/mmaps_generator

# copy it all
if [ ! -d "$MAPS_DIR" ]
then
  mkdir -p $MAPS_DIR
fi

cp -r dbc maps mmaps vmaps $MAPS_DIR
rm -r dbc maps mmaps vmaps Buildings
