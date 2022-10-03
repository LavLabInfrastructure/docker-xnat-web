FROM tomcat:9-jdk8-openjdk-buster

# Environment
ENV XNAT_VERSION="1.8.5.1"
ENV XNAT_ROOT="/data/xnat"
ENV XNAT_HOME="${XNAT_ROOT}/home"
ENV DBUSER="xnat"
ENV DBPASS="xnat"

# Build Args
ARG XNAT_DATASOURCE_DRIVER="org.postgresql.Driver"
ARG XNAT_DATASOURCE_URL="jdbc:postgresql://db/xnat"
ARG XNAT_EMAIL="mjbarrett@mcw.edu"
ARG XNAT_PROCESSING_URL="http://xnat:8080"
ARG XNAT_SMTP_ENABLED=false
ARG XNAT_SMTP_HOSTNAME="fake.fake"
ARG XNAT_SMTP_PORT=587
ARG XNAT_SMTP_AUTH=false
ARG XNAT_SMTP_USERNAME="user"
ARG XNAT_SMTP_PASSWORD="pass"
ARG TOMCAT_XNAT_FOLDER="ROOT"
ARG TOMCAT_XNAT_FOLDER_PATH="${CATALINA_HOME}/webapps/${TOMCAT_XNAT_FOLDER}"

# add files
ADD make-xnat-config.sh wait-for-postgres.sh install-plugins.sh /usr/local/bin/
ADD plugins.tsv /tmp/plugins.tsv

# install prereqs
RUN apt-get update && apt-get install -y postgresql-client wget gawk

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

# Install listed plugins and configure XNAT then clean up
RUN /usr/local/bin/make-xnat-config.sh && \
        /usr/local/bin/install-plugins.sh "/tmp/plugins.tsv"
RUN rm /usr/local/bin/make-xnat-config.sh /usr/local/bin/install-plugins.sh 

# Download specified version of XNAT, extract, and clean up
RUN wget --no-verbose --output-document=/tmp/xnat-web-${XNAT_VERSION}.war https://api.bitbucket.org/2.0/repositories/xnatdev/xnat-web/downloads/xnat-web-${XNAT_VERSION}.war
RUN unzip -o -d ${TOMCAT_XNAT_FOLDER_PATH} /tmp/xnat-web-${XNAT_VERSION}.war
RUN rm -f /tmp/xnat-web-${XNAT_VERSION}.war

# Entry
CMD ["wait-for-postgres.sh", "/usr/local/tomcat/bin/catalina.sh", "run"]

