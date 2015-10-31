#! /bin/bash

set -e

if [ -f "${HOME}/.pgpass" -o "${PGHOST}" ]; then

  echo "Checking if database is up..."

  # The port should be 5432 - this is assumed in some cases
  nc -zv ${PGHOST} ${PGPORT}

  if [ "$?" -ne "0" ]; then
    echo "PostgreSQL connection failed."
    exit 0
  fi

  CHK_QUARTZ=`echo "$(psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -l | grep quartz | wc -l)"`
  CHK_HIBERNATE=`echo "$(psql -U ${PGUSER}  -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -l | grep hibernate | wc -l)"`
  CHK_JCR=`echo "$(psql -U ${PGUSER}  -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -l | grep jackrabbit | wc -l)"`

  echo "quartz: ${CHK_QUARTZ}"
  echo "hibernate: ${CHK_HIBERNATE}"
  echo "jcr: ${CHK_JCR}"


  if [ "${CHK_JCR}" -eq "0" ]; then
    if [ "${RDS}" ]; then
      psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/rds/jackrabbit.sql
    else
      psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/create_jcr_postgresql.sql
    fi
  fi

  if [ "${CHK_HIBERNATE}" -eq "0" ]; then
    if [ "${RDS}" ]; then
      psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/rds/repository.sql
    else
      psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/create_repository_postgresql.sql
    fi
  fi


  if [ "${CHK_QUARTZ}" -eq "0" ]; then
    if [ "${RDS}" ]; then
      psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/rds/quartz.sql
    else
      psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/create_quartz_postgresql.sql
    fi
  fi

  # DI logging
  # psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/pentaho_logging_postgresql.sql

  # Sample data
  # psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -f $PENTAHO_HOME/server/biserver-ee/data/postgresql/pentaho_mart_postgresql.sql

fi
