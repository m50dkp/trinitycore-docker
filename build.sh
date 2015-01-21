cd TrinityCore
mkdir build
cd build

cmake ../ -DPREFIX=/build -DTOOLS=1 -DWITH_WARNINGS=1
make -j $(nproc)
make install
