#!/usr/bin/env sh

# Update config files

set -e

# TOOD: Currently doesn't work (Marketplace OSGI bundle doesn't seem to load)
if [ 6 -le "${PENTAHO_VERSION%.*.*.*}" ] && [ "${MARKETPLACE}" ]; then
  sed -i 's/\(featuresBoot=\)\(.*\)/\1\2,pentaho-marketplace/g' $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/karaf/etc/org.apache.karaf.features.cfg
fi

# TODO: Make this unnecessary
if [ ! -f ${PENTAHO_HOME}/.touched ]; then

  sed -i "s/localhost/$PGHOST/g" $CATALINA_HOME/webapps/pentaho/META-INF/context.xml
  sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository.xml
  sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml

  # TODO: Use perl
  sed -i '/<param-name>solution-path<\/param-name>.*/ {N; s#\(<param-name>solution-path<\/param-name>\).*<\/param-value>#\1\n\t\t<param-value>'"${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions"'<\/param-value>#}' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml

  # Get rid of sample data and disable HSQLDB
  rm -f ${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions/system/default-content/*.zip
  perl -0777 -i -pe 's/(<!-- \[BEGIN HSQLDB DATABASES\] -->)(.*)(<!-- \[END HSQLDB DATABASES\] -->)/$1\n    <!--    $2-->\n    $3/smg' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
  perl -0777 -i -pe 's/(<!-- \[BEGIN HSQLDB STARTER\] -->)(.*)(<!-- \[END HSQLDB STARTER\] -->)/$1\n    <!--    $2-->\n    $3/smg' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
  touch ${PENTAHO_HOME}/.touched

fi

if [ "${TOMCAT_DEBUG}" = "true" ]; then
  echo
  echo "==== Tomcat Debug ENABLED ===="
  export CATALINA_OPTS="${CATALINA_OPTS} -Xdebug -Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n"
fi

# Set up the database and start PBA
./setup-postgres.sh
if [ "${CLUSTERED}" ]; then ./setup-clustering.sh; fi
${CATALINA_HOME}/bin/catalina.sh run
