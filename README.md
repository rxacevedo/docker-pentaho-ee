# docker-pentaho-ee

[![Join the chat at https://gitter.im/rxacevedo/docker-pentaho-ee](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/rxacevedo/docker-pentaho-ee?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is a Dockerized deployment of the [Pentaho BA Server](http://www.pentaho.com/product/business-visualization-analytics) (Enterprise Edition). Because the enterprise distribution is not freely available online, the required archives must be placed in the `build` directory by the user. This also means (at present) that there can be no automated build on [Docker Hub](https://hub.docker.com/).

## Build

Copy your downloaded Pentaho EE archives into the `build` directory and build the image. As of this writing, the archives are expected to be named the way that they are when downloaded from Pentaho (via Box or the FTP).

```bash
docker build -t rxacevedo/docker-pentaho-ee .
```

## Run

```bash
docker-compose up
```

This will start up a Postgres database and link PBA to it via container linking/environment variables. Alternatively, you can do this via the command line:

```bash
docker run -d --name postgres postgres
docker run -it \
           -e PGUSER=postgres \
           -e PGHOST=postgres \
           -e PGPORT=5432 \
           -e PGDATABASE=postgres \
           -p 8080:8080 \
           --link postgres:postgres \
           rxacevedo/docker-pentaho-ee
```

You can then access Pentaho (which starts up unlicensed) at [http://DOCKER_HOST:8080/pentaho](http://DOCKER_HOST:8080/pentaho).

## Attribution
Pentaho BA Server is the sole property of [Pentaho Corporation](http://www.pentaho.com/).
