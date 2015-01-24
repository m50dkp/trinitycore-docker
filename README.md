# trinitycore-docker


See the [TrinityCore Installation Guide](http://collab.kpsn.org/display/tc/Installation+Guide) for useful
documentation on building TC from scratch.

The debian packages installed in this `Dockerfile` come from [here](http://collab.kpsn.org/display/tc/Requirements).

The `build_core.sh` reflects the [Core Installation](http://collab.kpsn.org/display/tc/Core+Installation).

## Build

```sh
$ docker build -t trinitycore .
```

Builds the trinity core project and tools. Tools are built to /usr/local/bin.
The resulting docker image has a custom entrypoint for executing various tasks
and running the resulting servers.

### data

The data command creates a [data-only][] container. A data-only container can
be used to persist and share data across multiple containers. This will be used
for extracting maps and passing them to the `worldserver`.

To create an empty data-only container run the following.

```sh
$ docker run --name my-data -it trinitycore data
```

Notice that container is started and immediately finishes executing. However,
the container still exists, and can be seen with `docker ps -a`

[data-only]: https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container

### extract-maps

> **Note**: Extracting maps can take hours.

The `extract_maps.sh` script expects the World of Warcraft (v3.3.5a) client
directory to be mounted to `/opt/wow-client`. Maps are extracted to
`/opt/trinitycore/maps`.

The following is an example of extracting the maps and saving them to
`~/WoW/ServerData` on the host machine. Assuming the WoW client is located at
`~/WoW/WoW3.3.5a`,

```sh
$ docker run --rm -it -v ~/WoW/WoW3.3.5a:/opt/wow-client -v ~/WoW/ServerData:/opt/trinitycore/maps trinitycore extract-maps
```

We use the `--rm` option because the extracted maps are written to the host,
thus the Docker container is no longer needed.

Once the maps are extracted we can mount the maps from the host into a data-only
container. The resulting container will be used by the `worldserver`.

```sh
$ docker create -it --name tc-maps -v ~/WoW/ServerData:/opt/trinitycore/maps trinitycore data
```

#### Advanced: Extracting maps into a Docker image

It is possible to extract maps into a Docker image. This is useful if you
plan on deploying to a remote server. Like before, assume the WoW client
is located at `~/WoW/WoW3.3.5a`.

```sh
$ docker run --name map-container -it -v ~/WoW/WoW3.3.5a:/opt/wow-client trinitycore extract-maps
```

We do __not__ use the `--rm` option in this case because the maps are written
into the Docker container's file system, not the host's. We also do not mount
`~/WoW/ServerData` to `/opt/trinitycore/maps`. When the extraction is complete,
the container will be stopped, but still exists. It can be found with

```sh
$ docker ps -a | grep map-container
```

Now the container can be committed into an image called `trinitycore-maps`.

```sh
$ docker commit map-container trinitycore-maps
```

After `map-container` is committed to an image, the container is not needed and
can be safely deleted. The resulting image can be pushed to a Docker registry,
and can be used to create data-only containers to use with `worldserver`.

```sh
$ docker create -it --name tc-maps trinitycore-maps data
```

In this example we created a data-only container called `tc-maps` from the
`trinitycore-maps` Docker image.

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

The worldserver depends on the extracted maps accessible at `/opt/trinitycore/maps`. In the below examples, this volume is provided by a container named `tc-maps`.

NOTE: in the following commands, the `-i` is very important when running in daemon mode. Without it, the servers will not actually start or will not later be accessible via interactive prompt using `docker attach`.

## Running the worldserver

You have two options:

1. Use the default configuration
2. Use a custom configuration

NOTE: in the following commands, the `-i` is very important when running in daemon mode. Without it, the servers will not actually start or will not later be accessible via interactive prompt using `docker attach`.

### Default Configuration File

The worldserver entry script in the trinitycore image will automatically copy over the default config into `/opt/trinitycore/conf/` if it does not exist.

```sh
$ docker run --name tc-worldserver -i -d --link tc-dbserver:TCDB -p 8085:8085 --volumes-from tc-maps trinitycore worldserver
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
