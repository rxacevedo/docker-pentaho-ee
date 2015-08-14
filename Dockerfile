FROM java:7

MAINTAINER rxacevedo@fastmail.com

# Set up environment
ENV PENTAHO_VERSION=5.4.0.1 PENTAHO_PATCH=130
ENV PENTAHO_HOME=/opt/pentaho
ENV COMPONENTS="biserver-manual-ee:paz-plugin-ee:pdd-plugin-ee:pentaho-analysis-ee:pentaho-mobile-plugin:pir-plugin-ee"

# Set up JAVA_HOME
RUN . /etc/environment
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64

ENV USER=drwho PASS=sekret

# Install Dependences
RUN apt-get update; \
    apt-get install wget unzip git vim -y; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p ${PENTAHO_HOME}/tmp; useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; chown pentaho:pentaho ${PENTAHO_HOME}

USER pentaho

# This is for development, Will be replaced by pulling deps from the FTP
ADD res/* /tmp/
# RUN wget -m -P /tmp ftp://${USER}:${PASS}@supportftp.pentaho.com/Enterprise%20Software/Pentaho_BI_Suite/${PENTAHO_VERSION}-GA/BA-Server/Manual%20Build/
RUN mkdir -p /tmp/extract
              
# Unzip the things
RUN for i in $(echo ${COMPONENTS} | tr ':' '\n'); \
    do echo "$i-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip"; \
    /usr/bin/unzip -q /tmp/"$i-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip" -d  ${PENTAHO_HOME}/tmp; \
    rm -rf /tmp/"$i-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip"; \
    done

WORKDIR $PENTAHO_HOME/tmp

# Run the installer headless
RUN for i in $(ls -d */); \
    do cd $i; \
    java -jar installer.jar /tmp/auto-install.xml; \
    cd ..; \
    done
  
##########################################
# Be sure to remove history if it exists #
##########################################

RUN rm -rf /tmp/*

CMD ["/bin/bash"]
