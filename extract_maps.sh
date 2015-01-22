#!/bin/bash

# It is expected that /opt/wow-client and /opt/trinitycore-data are provided
# via a mounted volume (-v) as part of `docker run`.

cd /opt/wow-client
/usr/local/bin/mapextractor -f 0
/usr/local/bin/vmap4extractor
/usr/local/bin/mmaps_generator
cp -r dbc maps mmaps vmaps /opt/trinitycore-data