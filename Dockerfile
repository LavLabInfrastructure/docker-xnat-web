FROM tomcat:9-jdk8-openjdk-buster

# Default Environment
ENV POSTGRES_HOST=db 
ENV POSTGRES_DB=xnat
ENV POSTGRES_USER=xnat
ENV POSTGRES_PASSWORD=password
ENV XNAT_VERSION=1.8.5.1
ENV XNAT_ROOT=/data/xnat
ENV XNAT_HOME=${XNAT_ROOT}/home
ENV XNAT_DATASOURCE_NAME=$POSTGRES_DB
ENV XNAT_DATASOURCE_USERNAME=$POSTGRES_USER
ENV XNAT_DATASOURCE_PASSWORD=$POSTGRES_PASSWORD
ENV XNAT_DATASOURCE_DRIVER=org.postgresql.Driver
ENV XNAT_DATASOURCE_URL=jdbc:postgresql://${POSTGRES_HOST}/${POSTGRES_DB}
ENV XNAT_EMAIL=mjbarrett@mcw.edu
ENV XNAT_PROCESSING_URL=http://xnat:8080
ENV XNAT_SMTP_ENABLED=false
ENV XNAT_SMTP_HOSTNAME=fake.fake
ENV XNAT_SMTP_PORT=587
ENV XNAT_SMTP_AUTH=false
ENV XNAT_SMTP_USERNAME=user
ENV XNAT_SMTP_PASSWORD=pass
ENV TOMCAT_XNAT_FOLDER=ROOT
ENV TOMCAT_XNAT_FOLDER_PATH=${CATALINA_HOME}/webapps/${TOMCAT_XNAT_FOLDER}

# install prereqs
RUN apt-get update && apt-get install -y postgresql-client gawk


# prepare Tomcat/XNAT directories
RUN rm -rf ${CATALINA_HOME}/webapps/*
RUN mkdir -p \
        ${TOMCAT_XNAT_FOLDER_PATH} \
        ${XNAT_HOME}/config \
        ${XNAT_HOME}/logs \
        ${XNAT_HOME}/plugins \
        ${XNAT_HOME}/work \
        ${XNAT_ROOT}/archive \
        ${XNAT_ROOT}/build \
        ${XNAT_ROOT}/cache \
        ${XNAT_ROOT}/ftp \
        ${XNAT_ROOT}/pipeline \
        ${XNAT_ROOT}/prearchive

# Download specified version of XNAT, extract, and clean up
RUN curl -qLo /tmp/xnat-web-${XNAT_VERSION}.war https://api.bitbucket.org/2.0/repositories/xnatdev/xnat-web/downloads/xnat-web-${XNAT_VERSION}.war
RUN unzip -o -d ${TOMCAT_XNAT_FOLDER_PATH} /tmp/xnat-web-${XNAT_VERSION}.war
RUN rm -f /tmp/xnat-web-${XNAT_VERSION}.war

# add files
ADD ./scripts/* /startup/
ADD ./resources/* /tmp/

# Entry
ENTRYPOINT "/startup/entrypoint.sh"

