

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

Running worldserver commands:

```sh
docker ps | grep worldserver
# take the name or container id and put it below
# generally will be "trinitycore-worldserver_1"
docker attach CONTAINER_NAME_OR_ID
# at worldserver prompt
TC>
# DO NOT CTRL+C, unless you want the worldserver to restart!
# Detatch let leave it running with: CTRL-p CTRL-q
```

Useful worldserver commands:

```sh
account create <user> <pass>
account set gmlevel <user> 3 -1 # give user GM power on all realms
```

Set your client's WoW-3.3.5a/Data/enUS/realmlist.wtf:

```sh
set realmlist localhost
```

And start your client! If you have an older mac still capable of running the client, you may need to remove the "quarantine" attribute to avoid "Failed to open archive interface.MPQ" errors:

```sh
cd /path/to/WoW-3.3.5a
xattr -r -d com.apple.quarantine *
```

An alternative workaround is to run the macos binary directly:

```sh
./path/to/WoW-3.3.5a/World\ of\ Warcraft/Contents/MacOS/World\ of\ Warcraft
```

Shutdown

```
docker-compose down
```

Manual DB Changes (such as https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130094/Networking#Networking-Settingtheauthdatabaserealmlistforinternetconnections)

[adminer](https://hub.docker.com/_/adminer) (aka phpMyAdmin) is included as a container. Using it requires the following:

1. Visit http://localhost:8080/?server=trinitycore-db&username=root . Note: trinitycore-db is the service name within the docker cluster, so that services within can discover each other.
1. Use your root password as specified in [docker-compose.yaml](./docker-compose.yaml).
1. Do whatever you need to do, like update your realmlist address with your client-accessible IP address:

```sql
use auth;
UPDATE realmlist
set 
  address='127.0.0.1'
  /*, localAddress='${USER_IP_ADDRESS}'*/
WHERE name='Trinity';
```

Questions / TODO

- [ ] containerfs vs hostfs. "containerfs" generally means "these folders will be docker `COPY`-ied to the root of the container. I'm doing the opposite, since I'm not `COPY`, I'm mounting as a bind volume

- [x] Update passwords / networking in *.conf
- ~[ ] Need to have some sort of update-ip command still https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130094/Networking#Networking-Settingtheauthdatabaserealmlistforinternetconnections~
- [ ] Add a "how this works" overview
- [x] Add a "accessing the db" section (adminer?)
- [x] Test a real client
- [x] Have a better pattern for passing the client in for extraction


Notes:

To start from scratch with the database: `rm -rf /containerfs/tc-db/mysql`