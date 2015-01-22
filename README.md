# trinitycore-docker

See the [TrinityCore Installation Guide](http://collab.kpsn.org/display/tc/Installation+Guide) for useful
documentation on building TC from scratch.

The debian packages installed in this `Dockerfile` come from [here](http://collab.kpsn.org/display/tc/Requirements).

The `build.sh` reflects the [Core Installation](http://collab.kpsn.org/display/tc/Core+Installation).

### Build

```sh
$ docker build . -t trinitycore
```

Builds the trinity core project and tools. Tools are built to /usr/local/bin

### Running the maps extractor

the `extract_maps.sh` script expects the World of Warcraft (v3.3.5a) client directory to be mounted to `/opt/wow-client`, and for a host directory to be mounted as `/opt/trinintycore-data` for the extracted data. The following command is an example of extracting the maps and saving them to `~/WoW/ServerData` on the host:

```sh
docker run -ti -v ~/Desktop/WoW/WoW3.3.5a:/opt/wow-client -v ~/Desktop/WoW/ServerData:/opt/trinitycore-data trinitycore /etc/extract_maps.sh
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