sed -i "s/localhost/$PGHOST/g" $CATALINA_HOME/webapps/pentaho/META-INF/context.xml
sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository.xml
sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml
sh setup_postgres.sh
