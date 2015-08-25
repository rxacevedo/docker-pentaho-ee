# docker-pentaho-ee

[![Join the chat at https://gitter.im/rxacevedo/docker-pentaho-ee](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/rxacevedo/docker-pentaho-ee?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is a Dockerized deployment of the [Pentaho BA Server](http://www.pentaho.com/product/business-visualization-analytics) (Enterprise Edition). Because the enterprise distribution is not freely available online, the required archives are downloaded from Pentaho's support FTP site using your credentials (from Pentaho support). This also means (at present) no automated build on [Docker Hub](https://hub.docker.com/).

## Build

```bash
docker build -t rxacevedo/docker-pentaho-ee PATH
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
           -e PGDATABASE=postgres \
           -p 8080:8080 \
           --link postgres:postgres \
           rxacevedo/docker-pentaho-ee
```

You can then access Pentaho (which starts up unlicensed) at http://<docker host>:8080/pentaho.

## TODO

- [x] Remove HSQLDB database/startup listener references from `web.xml`
- [x] Fix `SolutionContextListener.ERROR_0001 - Solution path is invalid` exception, this may be permissions-related. ~~Current workaround is to hard-code it in, although this shouldn't be necessary.~~ Yeah I'm still hardcoding this but it's scripted to fill in the right path (based on $PENTAHO_HOME) so it's all good.
- [ ] Only drop/create tables in DB if they don't already exist.

## Attribution
Pentaho BA Server is the sole property of [Pentaho Corporation](http://www.pentaho.com/).
