# trinitycore database

Builds and initializes a mariadb sql docker container.

See [this page](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130092/Databases+Installation) for instructions on installing
the TC database from scratch.

The root Docker image comes from [this](https://registry.hub.docker.com/_/mariadb/) image. There are others
and this was confusing at first.

This `Dockerfile` can be built independently from any other in this project.

## Build

```sh
docker build -t trinitycore-db .
```

Builds a mariadb database image for TrinityCore that contains the current create_sql script for 3.3.5
Rather than create multiples entry point we will just copy the file and go inside the container to init it.
The -p 3306:3306 will expose the port of the db container, so you can connect to it via an external SQL tool like dbeaver.

## Run the db and init it once

```sh
docker run -d --name tc-dbserver -p 3306:3306 --restart=always -v TC-db:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password trinitycore-db
```

This will run the container and mark it for restart once your computer restart, else you will have to run this command each time.

Once the container is started, we will attach to it and run the create script. 

```sh
docker exec -it tc-dbserver /bin/bash
```

Once inside the container, run the following to init the db. 
The first sed command will replace the default password (trinity currently) by your own secure password.
The second will make the user trinity able to connect from any ip address rather than just localhost.

```sh
cd /etc/db/sql
sed -i "s/IDENTIFIED BY '.*'/IDENTIFIED BY 'mysecurepassword'/" create_mysql.sql
sed -i 's/localhost/%/g' create_mysql.sql
mysql -uroot -ppassword < create_mysql.sql
```

This container will be accessed by the worldserver and authserver with the docker link command while the data will be persisted in the volume TC-db.

Please refer to the docker documentation on how to back up the data.

### The little gift.

If you have played Wow, you must know that the most annoying thing when you start without a higher level friend, 
is the lack of bag space.
So if you want to make it a little easier for you, once you have started the worldserver the first time, 
come back to the db container with the exec command and run the following that will add a quest to the first questgiver
for each race/faction.

Special thanks to mfi for this little script.

```sh
$ cd /etc/db/sql
$ mysql -uroot -ppassword < gift_bag.sql
```

Do not forget to connect to the worldserver and run the "reload all quest" command.
