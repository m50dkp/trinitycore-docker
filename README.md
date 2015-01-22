# trinitycore-docker

See the [TrinityCore Installation Guide](http://collab.kpsn.org/display/tc/Installation+Guide) for useful
documentation on building TC from scratch.

The debian packages installed in this `Dockerfile` come from [here](http://collab.kpsn.org/display/tc/Requirements).

The `build.sh` reflects the [Core Installation](http://collab.kpsn.org/display/tc/Core+Installation).

### Build

```sh
$ docker build .
```

Builds the trinity core project and tools. Tools are built to /usr/local/bin

TODO:
* Tools are built in the /build directory in the image. Will likely need those tools for map extraction, so
map extraction needs to happen in here?

