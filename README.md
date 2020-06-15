# trinitycore-docker


See the [TrinityCore Installation Guide](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130077/Installation+Guide) for useful
documentation on building TC from scratch.

The debian packages installed in this `Dockerfile` come from [here](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/10977288/Linux+Requirements).

The `build_core.sh` reflects the [Core Installation](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/10977309/Linux+Core+Installation).

## Build

git clone this repository and once inside run the command to build the container.

```sh
$ docker build -t trinitycore .
```

Builds the trinity core project and tools. Tools are built to /usr/local/bin.
The resulting docker image has a custom entrypoint for executing various tasks
and running the resulting servers.

### data

In order to persist data (and allow their backup), we will use docker volumes. We will need 3 of them 1 for the maps,
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
$ docker run --rm -it -v ~/WoW/WoW3.3.5a:/opt/wow-client -v ~/WoW/ServerData:/usr/local/trinitycore/data trinitycore extract-maps
```

We use the `--rm` option because the extracted maps are written to the host,
thus the Docker container is no longer needed.

Once the maps are extracted to the volume, we can use it in the worldserver container.

### Updating permissions and Realm IP Address

On mac, assuming you are running boot2docker (and thus want to use it's bridged NAT address as the entry):

```sh
$ docker run --rm -e MYSQL_ROOT_PASSWORD=password -e USER_IP_ADDRESS=$(boot2docker ip) trinitycore update-ip
```

If deploying to another server, it's likely you'll specify that server's address instead.

### help

Run the help command!

```sh
docker run --rm -it trinitycore help
```

# Worldserver and Authserver

The worldserver and authserver both depend on a database connection. Docker's `--link` command effectively exposes the ports of a running container to a new container via environment variables. Therefore, the [database container](db/README.md) must be running before attempting to start either the auth or world servers.

It is assumed that the name of the running db container is `tc-dbserver`.

The worldserver depends on the extracted maps accessible at `/usr/local/trinitycore/data`. In the below examples, this volume is provided by the volume we have created and populated above TC-maps.
 
NOTE: in the following commands, the `-i` is very important when running in daemon mode. Without it, the servers will not actually start or will not later be accessible via interactive prompt using `docker exec`.

## Running the worldserver

You have two options:

1. Use the default configuration
2. Use a custom configuration

NOTE: in the following commands, the `-i` is very important when running in daemon mode. Without it, the servers will not actually start or will not later be accessible via interactive prompt using `docker attach`.

### Default Configuration File

The worldserver entry script in the trinitycore image will automatically copy over the default config into `/opt/trinitycore/conf/` if it does not exist.

```sh
$ docker run --name tc-worldserver -i -d --link tc-dbserver:TCDB -p 8085:8085 -v TC-maps:/usr/local/trinitycore/data -v TC-config:/usr/local/trinitycore/etc trinitycore worldserver
```

### Custom Configuration

Grab [worldserver.conf.dist][], copy it somewhere on your system, and rename it to `worldserver.conf`. Make any modifications needed. You can ignore the mysql connection details, because those will be changed automatically by the entry script.

```sh
$ docker run --name tc-worldserver -i -d -v path/to/your/worldserver.conf:/opt/trinitycore/conf/worldserver.conf --link tc-dbserver:TCDB -p 8085:8085 --volumes-from tc-maps trinitycore worldserver
```

## Running the authserver

You have two options:

1. Use the default configuration
2. Use a custom configuration

### Default Configuration File

The authserver entry script in the trinitycore image will automatically copy over the default config into `/opt/trinitycore/conf/` if it does not exist.

```sh
$ docker run --name tc-authserver -i -d --link tc-dbserver:TCDB -p 3724:3724 trinitycore authserver
```

### Custom Configuration

Grab [authserver.conf.dist][], copy it somewhere on your system, and rename it to `authserver.conf`. Make any modifications needed. You can ignore the mysql connection details, because those will be changed automatically by the entry script.

```sh
$ docker run --name tc-authserver -i -d -v path/to/your/authserver.conf:/opt/trinitycore/conf/authserver.conf --link tc-dbserver:TCDB -p 3724:3724 trinitycore authserver
```

[worldserver.conf.dist]: https://github.com/TrinityCore/TrinityCore/blob/3.3.5/src/server/worldserver/worldserver.conf.dist
[authserver.conf.dist]: https://github.com/TrinityCore/TrinityCore/blob/3.3.5/src/server/authserver/authserver.conf.dist

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

and run [commands](http://collab.kpsn.org/display/tc/Server+Setup#ServerSetup-FinalSteps) on the `worldserver`

```sh
account create <user> <pass>
account set gmlevel <user> <gmlevel> <realmID>
```

something like this that creates an account with user and password then give that user super gm privileges across all realms:

```sh
account create ralf wow5ever
account set gmlevel ralf 3 -1
```
`ctrl + c` to detach from the process while keeping `worldserver` running in the background.
