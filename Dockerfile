FROM tomcat:9-jdk8-openjdk-buster
# Build Args
ARG XNAT_VERSION=1.8.5.1
ARG XNAT_ROOT=/data/xnat
ARG XNAT_HOME=${XNAT_ROOT}/home
ARG TOMCAT_XNAT_FOLDER=ROOT
ARG TOMCAT_XNAT_FOLDER_PATH=${CATALINA_HOME}/webapps/${TOMCAT_XNAT_FOLDER}

# Default Environment
ENV XNAT_VERSION=${XNAT_VERSION}
ENV XNAT_ROOT=${XNAT_ROOT}
ENV XNAT_HOME=${XNAT_HOME}
ENV POSTGRES_HOST=db 
ENV POSTGRES_DB=xnat
ENV POSTGRES_USER=xnat
ENV POSTGRES_PASSWORD=password
ENV XNAT_EMAIL=
ENV XNAT_PROCESSING_URL=
ENV XNAT_SMTP_ENABLED=false
ENV XNAT_SMTP_HOSTNAME=
ENV XNAT_SMTP_PORT=
ENV XNAT_SMTP_AUTH=false
ENV XNAT_SMTP_USERNAME=
ENV XNAT_SMTP_PASSWORD=

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

ADD ./resources/* /tmp/
ADD ./scripts/* /startup/
RUN /startup/install-plugins.sh 

RUN useradd --home /data/xnat/home xnat && \
        chown -R xnat:xnat /data /usr/local/

USER xnat

HEALTHCHECK CMD [ "curl", "-f", "http://localhost:8080" ]
ENTRYPOINT "/startup/entrypoint.sh"