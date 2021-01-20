trinitycore-docker
==================

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md) 

[TrinityCore](https://github.com/TrinityCore/TrinityCore#introduction) is an MMORPG Framework. This project Dockerizes its various components using docker-compose to reduce as much complexity as possible. All you need is Docker and a copy of the 3.3.5a WoW client (any platform).

Quickstart / Example
--------------------

```sh
./action tc-fetch
./action tc-build
./action tc-db-fetch
CLIENT_DIR=/absolutepath/to/installed/WoW3.3.5a ./action tc-extract
docker-compose up
```

See [Initial Setup](#initial-setup) for more details.

Overview
--------

You should be able to skip this section completely, and go directly to `Initial Setup`. But if would like more info about this repo and its structure, read on.

A few principles behind the approach this repo takes:

1. As simple as possible: reduce configuration, reduce code, reduce implicit structures and coupling between scripts. The fewer things that can be configured, and the less code you have, the more maintainable a system is.
1. Limited scope: this is for you and your friends to setup and play, not for a production-scale deployment. It should be as straightforward to run and debug as possible. This means some things are not configurable automatically, such as passwords.

### The `action` Command

This project uses an "action container" or "cloud builder" docker pattern in the form of the [`action`](./action) command seen below. The cloud builder pattern is a docker container that contains general tools, but operates on the contents of the host disk rather than files inside the container.

Therefore, although Docker is being used, all config files, the database, source code, and compiled binaries are stored outside of docker. This greatly simplifies the majority of operations for TrinityCore, since you don't need to worry as much about Docker itself.

### Project Layout and Conventions

#### General

- `/containerfs`: this folder will be mounted into the action container as `/hostfs`. One way to think about this is that when the docker container is running, reading/ a file in `/hostfs/*` is like reading a file on the system hosting docker.
- `/action`: A bash script that builds and executes the action container from `/tc-builder`.

#### Containerfs Details

- `/containerfs/bin`: Each script in this folder is accessible in the action container's PATH. These scripts are how stuff happen. They run in the action container and _NEVER_ on the host machine. They generally operate on `/hostfs` inside on the container.
- `/containerfs/tc-client`: this path only exists inside the action container if `CLIENT_DIR` is populated
- `/containerfs/tc-conf`: Where you should edit and store your worldserver/authserver conf files. The trinitycore-worldserver and trinitycore-authserver docker services both read from this directory.
- `/containerfs/tc-db/mysql`: Where the MySQL (really mariadb) service stores its database files.
- `/containerfs/tc-server/source`: The source (git repo) of TrinityCore. You can cd into this directory and pull the latest changes to update your server.
- `/containerfs/tc-server/dist`: After a successful build, TrinityCore outputs its build artifacts here (`bin` for all the binary executables and `etc` for example configs).
- `/containerfs/tc-wd`: The "working directory" for the running worldserver, and authserver. The initial SQL database and extracted maps will/must be placed here, and logs from the processes will also exist here.

Initial Setup
-------------

While this project tries to remove as much complication as possible, you still need some awareness of TrinityCore's requirements and general operation. [The documentation is very helpful](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130077/Installation+Guide).

You generally only need to do the following steps once.

First, clone this repository. Then:

```sh
# Clone/update the TrinityCore repo to the proper location (3.3.5 branch).
./action tc-fetch
# Build TrinityCore
./action tc-build
# Get the matching database backup that matches your TrinityCore build
./action tc-db-fetch

# Extract maps, this will take hours.
# Make sure CLIENT_DIR is the absolute path to your WoW client! You'll get a
# docker error otherwise.
CLIENT_DIR=/absolutepath/to/installed/WoW3.3.5a ./action tc-extract
```

Configuration
-------------

Each time your build TrinityCore, worldserver.conf.dist and authserver.conf.dist will be output to `/containerfs/tc-server/dist/etc`. You can compare these files to what will be used when running the services:

```sh
diff -u containerfs/tc-server/dist/etc/authserver.conf.dist containerfs/tc-conf/authserver.conf
# and
diff -u containerfs/tc-server/dist/etc/worldserver.conf.dist containerfs/tc-conf/worldserver.conf
```

Feel free to modify `/containerfs/tc-conf/*.conf` files as you see fit, but it's recommended to first get everything working with the repo as-is before you begin heavy customization.

Server Start / Boot
-------------------

```sh
docker-compose up
```

On first boot, the database container will start a temporary server to self-initialize. This takes time. After initialization, mysqld/mariadbd will restart and be accessible, allowing the other services to start. Watch the output and check for any errors. Nearly a gigbyte of SQL must be loaded eventually, so give it time.

Once the database is ready TrinityCore worldserver will autopopulate the database with everything it needs, and then startup. Finally, the authserver will boot once the worldserver is ready.

You'll know it's all ready when you see output like:

```sh
trinitycore-worldserver_1  | World initialized in 0 minutes 56 seconds
trinitycore-worldserver_1  | Starting up anti-freeze thread (60 seconds max stuck time)...
trinitycore-worldserver_1  | TrinityCore rev. 0b7b7f10f90e 2021-01-15 08:31:35 +0000 (HEAD branch) (Unix, RelWithDebInfo, Static) (worldserver-daemon) ready...
... # and eventually
trinitycore-authserver_1   | Added realm "Trinity" at 127.0.0.1:8085.
```

_Note: CTRL+C will stop all services. On subsequent runs, you might find daemon mode more useful (`docker-compose up -d`) so you don't need a terminal window open. See the [Docker Compose documentation](https://docs.docker.com/get-started/08_using_compose/) for more details._


Worldserver Terminal / Prompt
-----------------------------

Once the services are up, you'll need to create users and general TrinityCore tasks as outlined in [Final Server Steps](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/77971021/Final+Server+Steps). This project is slightly different, since Docker must be used to connect to TrinityCore's worldserver admin terminal:

```sh
docker ps | grep worldserver
# take the name or container id and put it below
# generally will be "trinitycore-worldserver_1"
docker attach trinitycore-worldserver_1
# at worldserver prompt:
TC>
# DO NOT CTRL+C, unless you want the worldserver to restart!
# Detatch instead: CTRL-p CTRL-q
```

Useful Worldserver Commands
---------------------------

Create a a GM user:

```sh
account create <user> <pass>
account set gmlevel <user> 3 -1 # give user GM power on all realms
```

Connecting to Your Server with a Client
---------------------------------------

Set your client's WoW-3.3.5a/Data/enUS/realmlist.wtf:

```sh
set realmlist localhost
```

And start your client! 

_Note for Mac Users: Apple deprecated 32-bit applications, making the 3.3.5a client unrunable natively._

If you have an older mac still capable of running the client, you may need to remove the "quarantine" attribute to avoid "Failed to open archive interface.MPQ" errors:_

```sh
cd /path/to/WoW-3.3.5a
xattr -r -d com.apple.quarantine *
```

An alternative workaround is to run the macos binary directly:

```sh
./path/to/WoW-3.3.5a/World\ of\ Warcraft/Contents/MacOS/World\ of\ Warcraft
```

Shutdown
--------

See [Docker Compose documentation](https://docs.docker.com/get-started/08_using_compose/), but generally:

```sh
docker-compose down # when running in daemon mode, otherwise just CTRL+C
```

Manual Database Updates
-----------------------

A common manual database change is [updating the auth database realmlist ip addresss](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130094/Networking#Networking-Settingtheauthdatabaserealmlistforinternetconnections).

```sql
use auth;
UPDATE realmlist
set 
  address='127.0.0.1' /* <-- Replace with whatever you need */
  /*, localAddress='${USER_IP_ADDRESS}'*/
WHERE name='Trinity';
```

You can either connect to the cluster using docker and run `mysql` manually, or use adminer/phpMyAdmin.

### Manual

```sh
# Root password is defined in docker-compose.yaml
docker-compose exec trinitycore-db mysql -uroot -psecurity-through-subnets
```

### Adminer / phpMyAdmin

[adminer](https://hub.docker.com/_/adminer) (aka phpMyAdmin) is included as a container. Using it requires the following:

1. Uncomment the service declaration in [docker-compose.yaml](./docker-compose.yaml) (it's commented out since it allows anyone with your IP address and root password to edit the database).
1. Visit http://localhost:8080/?server=trinitycore-db&username=root . Note: trinitycore-db is the service name within the docker cluster, so that services within can discover each other.
1. Use your root password as specified in [docker-compose.yaml](./docker-compose.yaml).
1. Do whatever you need to do, like update your realmlist address with your client-accessible IP address.


Updating the Server
-------------------

To save space (TrinityCore repo is > 6GB!), the `tc-fetch` action does a filtered clone. TrinityCore releases use tags. You can run `./action tc-fetch` again to always grab the latest tagged (aka official) release of the `3.3.5` branch.

```sh
./action tc-fetch
./action tc-build
```

You can also do it manually, if you'd like to have the full repo or a specific commit:

```sh
git -C containerfs/tc-server/source fetch
git -C containerfs/tc-server/source checkout 3.3.5 # or whatever branch/tag/release you'd like
./action tc-build
```

You can perform a clean build via:

```sh
git -C containerfs/tc-server/source clean -dfx
./action tc-build
```


Starting from Scratch
---------------------

The truly unique information is in the database, so generally you only need:

```sh
# delete the database
rm -rf containerfs/tc-db/mysql/
```

But if you'd like to fully start over, do the above and the following:

```sh
# delete the initial SQL
rm -rf containerfs/tc-wd/*.sql
# delete the source tree
rm -rf containerfs/tc-server/{dist,source}
# delete the maps, logs (CAUTION: MAPS TAKE HOURS TO REGEN!)
rm -rf containerfs/tc-wd/*
```

Contributing
------------

Any contributions are welcome, as long as they keep this project within scope: simplicity, ease of maintenance, and ease of use.

Additionally, please note that this project is released with a [Contributor Code of Conduct](./CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
