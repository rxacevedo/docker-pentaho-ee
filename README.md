# docker-pentaho-ee

This is a Dockerized deployment of the [Pentaho BA Server](http://www.pentaho.com/product/business-visualization-analytics) (Enterprise Edition). Because the enterprise distribution is not freely available online, the required archives must be placed in the `build` directory by the user.

## Build

Copy your downloaded Pentaho EE archives into the `build` directory and build the image (your favorite CI tool can do this). As of this writing, the archives are expected to be named the way that they are when downloaded from Pentaho (via Box or the FTP). The Dockerfile has a few parameters that need to be updated in order for the build to work:

- BASE_IMAGE - ex: `tomcat:7`
- PENTAHO_VERSION - ex: `5.4.0.1-130`

This is to allow the image to be built in CI by parameterizing/filling in these values as a pre-build step. Once this is done, the image can be built:

```bash
docker build -t seibelsbi/docker-pentaho-ee .
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

### Amazon RDS
If you are using Amazon RDS (Postgres), you will need to pass `-e RDS=true` when starting your container. This is because Amazon RDS' Postgres implemention has slightly different default permissions set up. You will also need to pass in/create a `.pgpass` file in the `$HOME` directory of the pentaho user for both `postgres` and `pentaho_user`. This will allow the `psql` client to connect to the database without the need for passwords to be passed on the CLI when applying the DDL.

### Clustering
If you would like to cluster the BA server, pass `-e CLUSTERED=true` when starting your container. This will cause the bootstrap script to use different configuration files for Jackrabbit and Quartz to facilitate clustering. The node name for the Jackrabbit journal will use the container's hostname.

## Attribution
Pentaho BA Server is the sole property of [Pentaho Corporation](http://www.pentaho.com/).
