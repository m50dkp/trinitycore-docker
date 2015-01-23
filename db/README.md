# trinitycore database

Builds and initializes a mysql docker container.

See [this page](http://collab.kpsn.org/display/tc/Databases+Installation) for instructions on installing
the TC database from scratch.

This [repo](https://github.com/wblankenship/docker-TrinityCore/blob/master/build_db/build.sh) provides a
decent database initialization script.

The root Docker image comes from [this](https://registry.hub.docker.com/_/mariadb/) image. There are others
and this was confusing at first.

This `Dockerfile` can be built independently from any other in this project.

## TODO

* unclear if we need the chmods at the end of the script
* fix all the hacks!
* explain the difference between this `data` and the other `data`, i.e. the
importance of `VOLUME`

## Build

```sh
$ docker build -t trinitycore-mysql .
```

Builds a mysql database image for TrinityCore. The resulting docker image has a
custom entrypoint for executing various tasks and running the mysql database.

### data

The data command creates a [data-only][] container. A data-only container can
be used to persist and share data across multiple containers.

[data-only]: https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container

### mysqld

Starts the mysql database. You should create a data-only container to mount
into this container. For example, to create an empty data-only container,

```sh
$ docker run --name tc-mysql-data -it trinitycore-mysql data
```

then mount the resulting container's volumes when starting the database.

```sh
$ docker run --name tc-mysql-server --volumes-from tc-mysql-data -d -e MYSQL_ROOT_PASSWORD=password trinitycore-mysql mysqld
```

If the data-only container does not contain any database information, the
`install.sh` script will be executed.

We can connect a mysql-admin with a local copy, as long as you have the proper
ip address of the running vm (in the case of boot2docker):

```sh
$ boot2docker ip
192.168.59.103
$ mysql -uroot -ppassword -h192.168.59.103
mysql> show databases;
```

Still another problem: the create scripts for the trinity user grant permissions based on localhost, so we need to fix those:

```sh
mysql> GRANT ALL PRIVILEGES ON `world` . * TO 'trinity'@'%' WITH GRANT OPTION;
mysql> GRANT ALL PRIVILEGES ON `characters` . * TO 'trinity'@'%' WITH GRANT OPTION;
mysql> GRANT ALL PRIVILEGES ON `auth` . * TO 'trinity'@'%' WITH GRANT OPTION;
```

Then to actually connect the world server... edit the datadir in worldserver.conf to point at `/opt/trinitycore-data/`, and the mysql config to use the boot2docker ip above.

But then the default realm is set to 127.0.0.1, so to change that:

```sh
mysql> use auth;
mysql> update realmlist set address='192.168.59.103', localAddress='192.168.59.103' where name = 'Trinity';
```
