sed -i "s/localhost/$PGHOST/g" $CATALINA_HOME/webapps/pentaho/META-INF/context.xml
sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository.xml
