#/bin/bash

cd $TC_DIR/TrinityCore
mkdir build
cd build

cmake ../ -DBOOST_INCLUDEDIR=/usr/include/boost -DCMAKE_SYSTEM_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/ -DPREFIX=/usr/local -DTOOLS=1 -DWITH_WARNINGS=1
make -j $(nproc)
make install
