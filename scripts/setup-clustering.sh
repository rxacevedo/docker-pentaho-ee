#!/usr/bin/env sh

set -e

NODE_ID=$(hostname)

sed -i "s/Unique_ID/${NODE_ID}/g" ${PENTAHO_HOME}/cluster/repository.xml
sed -i "s/HOST/${PGHOST}/g" ${PENTAHO_HOME}/cluster/repository.xml
sed -i "s/PORT/${PGPORT}/g" ${PENTAHO_HOME}/cluster/repository.xml

cp ${PENTAHO_HOME}/cluster/repository.xml ${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository.xml
cp ${PENTAHO_HOME}/cluster/quartz.properties ${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions/system/quartz/quartz.properties
