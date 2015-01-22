#!/bin/bash

# It is expected that /opt/wow-client and /opt/trinitycore-data are provided
# via a mounted volume (-v) as part of `docker run`.

cd /opt/wow-client

# kill existings
rm -r dbc maps mmaps vmaps

# dbc, maps
/usr/local/bin/mapextractor -f 0

# vmaps
/usr/local/bin/vmap4extractor
mkdir vmaps
/usr/local/bin/vmap4assembler Buildings vmaps

# mmaps
/usr/local/bin/mmaps_generator

# copy it all
cp -r dbc maps mmaps vmaps /opt/trinitycore-data
rm -r dbc maps mmaps vmaps
