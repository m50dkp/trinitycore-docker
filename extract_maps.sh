#!/bin/bash

set -e

# It is expected that /opt/wow-client and /opt/trinitycore-data are provided
# via a mounted volume (-v, or --volumes-from) as part of `docker run`.

DIRS=(dbc maps mmaps vmaps Buildings)
BIN=/usr/local/bin/

cd /opt/wow-client

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
cp -r dbc maps mmaps vmaps /opt/tc/maps
rm -r dbc maps mmaps vmaps Buildings
