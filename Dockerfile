FROM #BASE_IMAGE#

MAINTAINER rxacevedo@fastmail.com

# Set up environment
ENV PENTAHO_VERSION=#PENTAHO_VERSION#
ENV PENTAHO_HOME=/opt/pentaho
ENV SOLUTION_PATH=${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions

# Components to be installed
ENV COMPONENTS=biserver-manual-ee:paz-plugin-ee:pdd-plugin-ee:pentaho-mobile-plugin:pir-plugin-ee
ENV COMPONENTS_DIR=/tmp/components

# Install Dependences
RUN apt-get update && apt-get install -y \
    git \
    netcat \
    postgresql-client-9.4 \
    unzip \
    wget \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Get PBA EE
COPY build /tmp/
COPY patches /tmp/patches/
COPY scripts ${PENTAHO_HOME}/scripts/
COPY rds ${PENTAHO_HOME}/rds/
COPY cluster ${PENTAHO_HOME}/cluster/

# Postgres driver
ADD https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar ${CATALINA_HOME}/lib/

RUN useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; \
    chown -R pentaho:pentaho ${PENTAHO_HOME} ${CATALINA_HOME} /tmp

USER pentaho

################################################################################
# NOTE: Owning /tmp up front and passing the Pentaho files in already unzipped #
# shaves almost 2GB from the image.                                            #
################################################################################

# Unzip components, removing the archives as we go
# RUN for PKG in $(echo ${COMPONENTS} | tr ':' '\n'); \
#     do echo "Unzipping $PKG-${PENTAHO_VERSION}-dist.zip..."; \
#     unzip -q /tmp/$PKG-${PENTAHO_VERSION}-dist.zip -d /tmp; \
#     rm -rf /tmp/$PKG-${PENTAHO_VERSION}-dist.zip; \
#     done

WORKDIR /tmp

# Run the installers headless
RUN for DIR in $(ls -d */ | grep -v 'patches'); \
    do \
    ${PENTAHO_HOME}/scripts/run-installer.sh ${DIR}; \
    rm -rf ${DIR}; \
    done

#########################################################################################
# Explode the wars in advance so that we can update files without having to boot Tomcat #
#########################################################################################

WORKDIR ${COMPONENTS_DIR}

RUN BISERVER_DIR=$(ls -d */ | grep biserver | sed 's/\///'); \
    mkdir -p ${CATALINA_HOME}/webapps/pentaho; \
    mkdir -p ${CATALINA_HOME}/webapps/pentaho-style; \
    unzip -q ${BISERVER_DIR}/pentaho.war -d ${CATALINA_HOME}/webapps/pentaho; \
    rm -rf ${BISERVER_DIR}/pentaho.war; \
    unzip -q ${BISERVER_DIR}/pentaho-style.war -d ${CATALINA_HOME}/webapps/pentaho-style; \
    rm -rf ${BISERVER_DIR}/pentaho-style.war; \
    mkdir -p ${PENTAHO_HOME}/server/biserver-ee; \
    unzip -q ${BISERVER_DIR}/pentaho-solutions.zip -d ${PENTAHO_HOME}/server/biserver-ee; \
    rm -rf ${BISERVER_DIR}/pentaho-solutions.zip; \
    unzip -q ${BISERVER_DIR}/pentaho-data.zip -d ${PENTAHO_HOME}/server/biserver-ee; \
    rm -rf ${BISERVER_DIR}/pentaho-data.zip; \
    unzip -q ${BISERVER_DIR}/license-installer.zip -d ${PENTAHO_HOME}/server; \
    rm -rf ${BISERVER_DIR}

# Hackaround for docker/docker#4570
RUN cp -r * ${PENTAHO_HOME}/server/biserver-ee/pentaho-solutions/system; \
    rm -rf *

RUN ln -s ${CATALINA_HOME} ${PENTAHO_HOME}/server/biserver-ee/tomcat

# Install patches
WORKDIR /tmp/patches

RUN for ZIP in $(ls | grep zip | sort); do \
    OUT_DIR="${ZIP%.*}"; \
    echo "Unizipping ${ZIP} to ${OUT_DIR}..."; \
    unzip -q ${ZIP}; \
    NEW_ZIP=$(ls ${OUT_DIR}/BIServer/ | grep '.zip' | head -n1); \
    echo "Unizipping ${NEW_ZIP} to biserver-ee..."; \
    unzip -o -q -d ${PENTAHO_HOME}/server/biserver-ee/ ${OUT_DIR}/BIServer/${NEW_ZIP}; \
    done

#######################
# Start the BA Server #
#######################

WORKDIR ${PENTAHO_HOME}/scripts

VOLUME ["${CATALINA_HOME}/logs"]

CMD ["sh", "startup.sh"]
