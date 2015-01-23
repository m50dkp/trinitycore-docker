# trinitycore-docker


See the [TrinityCore Installation Guide](http://collab.kpsn.org/display/tc/Installation+Guide) for useful
documentation on building TC from scratch.

The debian packages installed in this `Dockerfile` come from [here](http://collab.kpsn.org/display/tc/Requirements).

The `build.sh` reflects the [Core Installation](http://collab.kpsn.org/display/tc/Core+Installation).

## TODO

* update extract_maps to write to /opt/trinitycore-data if possible.
that way we can mount the client data as read-only. currently the map data is
written to the client directory first then manually moved over with `cp`.
* add a 'help' command to the entrypoint scripts.

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

The `extract_maps.sh` script expects the World of Warcraft (v3.3.5a) client
directory to be mounted to `/opt/wow-client`, and for a volume to be mounted as
`/opt/trinintycore-data` for the extracted data. A data-only container should
be used for `/opt/trinitycore-data`.

The following is an example of extracting the maps and saving them to
`~/WoW/ServerData` on the host machine.

First, create a data-only container using the `data` command, and mount the
host volume with the `-v` option.

```sh
$ docker run --name tc-map-data -v ~/WoW/ServerData:/opt/trinitycore-data -it trinitycore data
```

Note that we used the `--name` option to provide a custom name to our container.
Once there is a data-only container, we can run the `extract-maps` command.

```sh
$ docker run --rm --volumes-from tc-map-data -it -v ~/Desktop/WoW/WoW3.3.5a:/opt/wow-client trinitycore extract-maps
```

The `--volumes-from` command will map `/opt/trinitycore-data` to
`~/WoW/ServerData` via the data-only container. The `-v` option mounts the
location of the WoW client on the host machine to the expected location
within the container.

Alternatively, if maps are already extracted, they can be mounted into the
data-only container directly, thus avoiding the lengthy extraction process.
Assuming our maps are located in `~/wow/maps`

```sh
$ docker run --name tc-map-data -it -v ~/wow/maps/:/opt/trinitycore-data trinitycore data
```

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



### Running the worldserver

TODO: figure out DB stuff

Grab [worldserver.conf.dist][], copy it to your `ServerData` folder, and rename it to `worldserver.conf`. Make any modifications needed, such as database credentials (hopefully this isn't necessary eventually), and then run something like:

```sh
docker run -ti -v --name worldserver ~/Desktop/WoW/ServerData:/opt/trinitycore-data trinitycore /usr/local/bin/worldserver -c /opt/trinitycore-data/worldserver.conf
```

### Running the authserver

TODO: figure out DB stuff

Grab [authserver.conf.dist][], copy it to your `ServerData` folder, and rename it to `authserver.conf`. Make any modifications needed, such as database credentials (hopefully this isn't necessary eventually), and then run something like:

```sh
docker run -ti -v --name authserver ~/Desktop/WoW/ServerData:/opt/trinitycore-data trinitycore /usr/local/bin/authserver -c /opt/trinitycore-data/authserver.conf
```


[worldserver.conf.dist]: https://github.com/TrinityCore/TrinityCore/blob/3.3.5/src/server/worldserver/worldserver.conf.dist
[authserver.conf.dist]: https://github.com/TrinityCore/TrinityCore/blob/3.3.5/src/server/authserver/authserver.conf.dist


### Attaching to create/modify accounts


assuming that the `worldserver` is running detached as described above, attach to it:

```sh
docker attach --sig-proxy=false worldserver
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
