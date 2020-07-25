# trinitycore-docker


This repository is meant to install the 3.3.5 branch only.

See the [TrinityCore Installation Guide](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130077/Installation+Guide) for useful
documentation on building TC from scratch.

The debian packages installed in this `Dockerfile` come from [here](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/10977288/Linux+Requirements).

The `build_core.sh` reflects the [Core Installation](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/10977309/Linux+Core+Installation).

## Build

git clone this repository and once inside run the command to build the container.

```sh
docker build -t trinitycore .
```

Builds the trinity core project and tools. Tools are built to /usr/local/bin.
The resulting docker image has a custom entrypoint for executing various tasks
and running the resulting servers.

(This image is huge! 8.8Gb and you cannot remove the source once compiled as you need some sql files inside the repo on the first start.)

### data

In order to persist data (and allow their backup), we will use docker volumes. We will need 3 of them: 1 for the maps,
 1 for the database and 1 for the config file
 
 ```
docker volume create TC-maps
docker volume create TC-config
docker volume create TC-db
```

### extract-maps

> **Note**: Extracting maps can take hours.

The `extract_maps.sh` script expects the World of Warcraft (v3.3.5a) client
directory to be mounted to `/opt/wow-client`. Maps are extracted to
`/usr/local/trinitycore/data`.

The following is an example of extracting the maps and saving them to the volume TC-maps. Assuming the WoW client is located at
`~/WoW/WoW3.3.5a`,

```sh
docker run --rm -it -v ~/WoW/WorldofWarcraft-3.3.5:/opt/wow-client -v TC-maps:/opt/trinitycore/maps trinitycore extract-maps
```

We use the `--rm` option because the extracted maps are written to the host,
thus the Docker container is no longer needed.

Once the maps are extracted to the volume, we can use it in the worldserver container.

### help

Run the help command!

```sh
docker run --rm -it trinitycore help
```

# Worldserver and Authserver

The worldserver and authserver both depend on a database connection. Docker's `--link` command effectively exposes the ports of a running container to a new container 
via environment variables. Therefore, the [database container](db/README.md) must be running before attempting to start either the auth or world servers.

It is assumed that the name of the running db container is `tc-dbserver`.

The worldserver depends on the extracted maps accessible at `/usr/local/trinitycore/data`. In the below examples, this is provided by the volume we have created 
and populated above: TC-maps.
 
NOTE: in the following commands, the `-i` is very important when running in daemon mode. Without it, the servers will not actually start or will not later be accessible 
via interactive prompt using `docker exec`.

## Running the worldserver for the first time.

As the worldserver will ask if we want to create the database the first time (even with the worldserver.conf Updates section enabled), we will need to connect in interactive mode.

```sh
docker run --name tc-worldserverinit --rm -it --link tc-dbserver:TCDB -p 8085:8085 -v TC-maps:/usr/local/trinitycore/data -v TC-config:/usr/local/trinitycore/etc trinitycore worldserver
```


Once the initialization is done, you can CTRL+C to stop the worldserver and remove the container (thanks to the --rm option).

This step will either copy the default worldserver.conf to a location corresponding to the TC-config volume or re-use the one already there.
Once the database is created, you can access the worldserver.conf from your volume and modify it to suit your needs 
(under linux the file will be under /var/lib/docket/volumes/TC-config/_data).


## Running the worldserver once initialization is done.

```sh
docker run --name tc-worldserver -i -d --link tc-dbserver:TCDB -p 8085:8085 -v TC-maps:/usr/local/trinitycore/data -v TC-config:/usr/local/trinitycore/etc trinitycore worldserver
```

This will make the worldserver runs in the background.

If you want the container to restart automatically, when you restart your PC/server, just add the option --restart=always

### Updating the Realm IP Address

In order to allow other computer on the network to connect to the worldserver, you will need to set your host address in the reamlist table.
You can get your address with shell command: 

```sh
ip a
```
and select the one corresponding to your address on your internal network (or your external IP if you want to allow from internet)

```sh
docker run --rm --link tc-dbserver:TCDB -e MYSQL_ROOT_PASSWORD=password -e USER_IP_ADDRESS=192.168.1.1 trinitycore update-ip
```

## Running the authserver

```sh
docker run --name tc-authserver -i -d --link tc-dbserver:TCDB -p 3724:3724 -v TC-config:/usr/local/trinitycore/etc trinitycore authserver
```

This will run the authserver in daemon mode and either copy the default authserver.conf file to the TC-config container or use the one already present in it.
If you want the container to restart automatically, when you restart your PC/server, just add the option --restart=always

## Setting your client to connect to the authserver

You will have to set the realmlist option in you config.wtf file to the value you have used to update-ip:
```
ip a
```


## Default configuration file for world and auth servers


[worldserver.conf.dist](https://github.com/TrinityCore/TrinityCore/blob/3.3.5/src/server/worldserver/worldserver.conf.dist)
[authserver.conf.dist](https://github.com/TrinityCore/TrinityCore/blob/3.3.5/src/server/authserver/authserver.conf.dist)


## Stopping / Starting the world and auth servers

```sh
$ docker stop tc-worldserver
$ docker stop tc-authserver
```

```sh
$ docker start tc-worldserver
$ docker start tc-authserver
```

## Attaching to create/modify accounts


assuming that the `worldserver` is running detached as described above, attach to it:

```sh
docker attach --sig-proxy=false tc-worldserver
```

and run [commands](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/77971021/Final+Server+Steps) on the `worldserver`

```sh
account create <user> <pass>
account set gmlevel <user> <gmlevel> <realmID>
```

something like this that creates an account with user and password then give that user super gm privileges across all realms:

```sh
account create ralf wow5ever
account set gmlevel ralf 3 -1
```
/!\ This is the old way to set privileges. Please note it will be deprecated in the future version of TC.

`ctrl + c` to detach from the process while keeping `worldserver` running in the background.
