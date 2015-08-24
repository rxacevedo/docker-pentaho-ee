sed -i "s/localhost/$PGHOST/g" $CATALINA_HOME/webapps/pentaho/META-INF/context.xml
sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository.xml
sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml
# This one was fun to figure out...
sed -i '/<param-name>solution-path<\/param-name>.*/ {N; s#\(<param-name>solution-path<\/param-name>\).*<\/param-value>#\1\n\t\t<param-value>'"${PENTAHO_HOME}server/biserver-ee/pentaho-solutions"'<\/param-value>#}' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
sh setup_postgres.sh
