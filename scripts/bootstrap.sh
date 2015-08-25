sed -i "s/localhost/$PGHOST/g" $CATALINA_HOME/webapps/pentaho/META-INF/context.xml
sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/jackrabbit/repository.xml
sed -i "s/localhost/$PGHOST/g" $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml
sed -i '/<param-name>solution-path<\/param-name>.*/ {N; s#\(<param-name>solution-path<\/param-name>\).*<\/param-value>#\1\n\t\t<param-value>'"${PENTAHO_HOME}server/biserver-ee/pentaho-solutions"'<\/param-value>#}' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
# Ok fine I'll use perl
perl -0777 -i -pe 's/(<!-- \[BEGIN HSQLDB DATABASES\] -->.*<!-- \[END HSQLDB DATABASES\] -->)/<!--\n    $1\n    -->/smg' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
perl -0777 -i -pe 's/(<!-- \[BEGIN HSQLDB STARTER\] -->.*<!-- \[END HSQLDB STARTER\] -->)/<!--\n    $1\n    -->/smg' $CATALINA_HOME/webapps/pentaho/WEB-INF/web.xml
rm -f $PENTAHO_HOME/server/biserver-ee/pentaho-solutions/system/default-content/*.zip
sh setup_postgres.sh
