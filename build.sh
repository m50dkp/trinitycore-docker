cd $TC_DIR/TrinityCore
mkdir build
cd build

cmake ../ -DPREFIX=/usr/local -DTOOLS=1 -DWITH_WARNINGS=1
make -j $(nproc)
make install
