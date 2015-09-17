FROM tomcat:7

MAINTAINER rxacevedo@fastmail.com

# Set up environment
ENV PENTAHO_VERSION=5.4.0.1 PENTAHO_PATCH=130
ENV PENTAHO_HOME=/opt/pentaho

# Components to be installed
ENV COMPONENTS="biserver-manual-ee:paz-plugin-ee:pdd-plugin-ee:pentaho-analysis-ee:pentaho-mobile-plugin:pir-plugin-ee"

# Set up JAVA_HOME
RUN . /etc/environment
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
ENV PENTAHO_JAVA_HOME ${JAVA_HOME}

# Install Dependences
RUN apt-get update; \
    apt-get install wget netcat unzip git postgresql-client-9.4 vim -y; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Get PBA EE
COPY build /tmp/
COPY scripts ${PENTAHO_HOME}/scripts/

##################################
# Bring down and install Pentaho #
##################################


# Unzip components, removing the archives as we go
RUN for PKG in $(echo ${COMPONENTS} | tr ':' '\n'); \
    do echo "Unzipping $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip..."; \
    unzip -q /tmp/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip -d /tmp; \
    rm -rf /tmp/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip; \
    done

WORKDIR /tmp

# Run the installers headless
RUN for DIR in $(ls -d */); \
    do echo "Installing $DIR..."; \
    java -jar $DIR/installer.jar auto-install.xml 2>/dev/null; \
    rm -rf $DIR; \
    done

#########################################################################################
# Explode the wars in advance so that we can update files without having to boot Tomcat #
#########################################################################################

WORKDIR /tmp/components

RUN mkdir -p ${CATALINA_HOME}/webapps/pentaho; \
    mkdir -p ${CATALINA_HOME}/webapps/pentaho-style; \
    unzip -q biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho.war -d ${CATALINA_HOME}/webapps/pentaho; \
    rm -rf biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho.war; \
    unzip -q biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho-style.war -d ${CATALINA_HOME}/webapps/pentaho-style; \
    rm -rf biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho-style.war

# This is the folder structure that Pentaho expects
RUN mkdir -p ${PENTAHO_HOME}/server/biserver-ee

# Move pentaho-solutions and data into place
RUN unzip -q biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho-solutions.zip -d ${PENTAHO_HOME}/server/biserver-ee; \
    rm -rf biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho-solutions.zip; \
    unzip -q biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho-data.zip -d ${PENTAHO_HOME}/server/biserver-ee; \
    rm -rf biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/pentaho-data.zip; \
    unzip -q biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}/license-installer.zip -d ${PENTAHO_HOME}/server; \
    rm -rf biserver-manual-${PENTAHO_VERSION}-${PENTAHO_PATCH}

# Hackaround for docker/docker#4570
RUN cp -r * ${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions/system; \
    rm -rf *

RUN ln -s ${CATALINA_HOME} ${PENTAHO_HOME}/server/biserver-ee/tomcat

###########################################
# Update config and populate the database #
###########################################

# Need Postgres driver
ADD https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar ${CATALINA_HOME}/lib/

RUN useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; \
    chown -R pentaho:pentaho ${PENTAHO_HOME} ${CATALINA_HOME}

#######################
# Start the BA Server #
#######################

USER pentaho
WORKDIR ${PENTAHO_HOME}/scripts

CMD ["sh", "startup.sh"]
