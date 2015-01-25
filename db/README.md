# trinitycore database

Builds and initializes a mysql docker container.

See [this page](http://collab.kpsn.org/display/tc/Databases+Installation) for instructions on installing
the TC database from scratch.

This [repo](https://github.com/wblankenship/docker-TrinityCore/blob/master/build_db/build.sh) provides a
decent database initialization script.

The root Docker image comes from [this](https://registry.hub.docker.com/_/mariadb/) image. There are others
and this was confusing at first.

This `Dockerfile` can be built independently from any other in this project.

## Build

```sh
$ docker build -t trinitycore-db .
```

Builds a mysql database image for TrinityCore. The resulting docker image has a
custom entrypoint for executing various tasks and running the mysql database.

### data

The data command creates a [data-only][] container. A data-only container can
be used to persist and share data across multiple containers. It is assumed you create a data-only container first before running anything else.

```sh
$ docker run --name tc-mysql-data trinitycore-db data
```

`tc-mysql-data` is now a container where all mysql data can persist.

[data-only]: https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container

### init

Initializes mysql it with the base [TDB](http://collab.kpsn.org/display/tc/Databases+Installation).

```sh
$ docker run --rm -ti --volumes-from tc-mysql-data -e MYSQL_ROOT_PASSWORD=password trinitycore-db init
```

### mysqld

Starts the mysql database. Note the use of `--volumes-from` to pull in the persisted database data from the `tc-mysql-data` container, as well as the `-d` for daemon mode. The name used, `tc-dbserver`, will be used to later link this container to the world and auth servers.

```sh
$ docker run -d --name tc-dbserver --volumes-from tc-mysql-data -e MYSQL_ROOT_PASSWORD=password trinitycore-db mysqld
```

## Acessing the database via `mysql` command

The `mysqld` entrypoint command above does not expose the internal mysql port, 3306, to anything outside the docker container. This is a bit of a security measure, so that only another docker container can access mysql.

Here is an example of connecting with root credentials and executing a simple `SELECT` statement:

```sh
$ docker run --rm --link tc-dbserver:TCDB trinitycore-db mysql -hTCDB -uroot -ppassword -e 'select * from characters.characters;'
```

