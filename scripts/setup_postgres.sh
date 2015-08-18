#! /bin/bash

psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/create_jcr_postgresql.sql
psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/create_repository_postgresql.sql
psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/create_quartz_postgresql.sql
# psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/pentaho_logging_postgresql.sql
psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/pentaho_mart_postgresql.sql
