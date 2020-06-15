#/bin/bash

cd $TC_DIR/TrinityCore
mkdir build
cd build

cmake ../ -DCMAKE_INSTALL_PREFIX=$TC_DIR
make -j $(nproc)
make install
