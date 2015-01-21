# trinitycore database

Builds and initializes a mysql docker container.

See [this page](http://collab.kpsn.org/display/tc/Databases+Installation) for instructions on installing
the TC database from scratch.

This [repo](https://github.com/wblankenship/docker-TrinityCore/blob/master/build_db/build.sh) provides a
decent database initialization script.

The root Docker image comes from [this](https://registry.hub.docker.com/_/mariadb/) image. There are others
and this was confusing at first.

This `Dockerfile` can be built independently from any other in this project.

TODO:
* unclear if we need the chmods at the end of the script
* add some logging?

### Build

```sh
$ docker build .
```



