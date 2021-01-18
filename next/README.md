

Initial Setup

```sh
./action tc-clone
./action tc-build
./action tc-db-fetch

# Extract maps, this will take hours.
# Make sure CLIENT_DIR is the absolute path to your WoW client! You'll get a
# docker error otherwise.
CLIENT_DIR=/absolutepath/to/installed/WoW3.3.5a ./action tc-extract
```

Modify /containerfs/tc-conf/*.conf files if you'd like

Boot (first time)

```sh
docker-compose up
```

First boot, the database container will start a temporary server to self-initialize. This takes time. After initialization, mysqld will will restart and be accessible, allowing the other services to start.

```sh
docker-compose up -d
```



Shutdown

```
docker-compose down
```

Questions / TODO

- [ ] containerfs vs hostfs. "containerfs" generally means "these folders will be docker `COPY`-ied to the root of the container. I'm doing the opposite, since I'm not `COPY`, I'm mounting as a bind volume

- [x] Update passwords / networking in *.conf
- [ ] Need to have some sort of update-ip command still https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130094/Networking#Networking-Settingtheauthdatabaserealmlistforinternetconnections
- [ ] Add a "how this works" overview
- [ ] Add a "accessing the db" section (adminer?)
- [ ] Test a real client
- [x] Have a better pattern for passing the client in for extraction


Notes:

To start from scratch with the database: `rm -rf /containerfs/tc-db/mysql`