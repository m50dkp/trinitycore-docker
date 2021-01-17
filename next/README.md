

Initial Setup

```sh
./action tc-clone
./action tc-build
cp -r path/to/installed/WoW3.3.5a ./containerfs/tc-extraction/
./action tc-extract "/hostfs/tc-extraction/WoW3.3.5a"

./action tc-db-init
```

Boot

```sh
docker-compose up
```