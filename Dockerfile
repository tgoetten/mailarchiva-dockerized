FROM debian:bullseye

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y default-jre \
  libtcnative-1 \
  wget \
  curl \
  unzip

# Set environment variable JAVA_HOME to run Java based on Host architecture
ARG TARGETPLATFORM
ENV if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE=arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=amd64; fi \
    && JAVA_HOME="/usr/lib/jvm/java-8-openjdk-${ARCHITECTURE}/jre"

# (further) set environment variables relevant for Tomcat
ENV MAILARCHIVA_WAR=mailarchiva_v8.12.16.war \
    TOMCAT_MAJOR=7 \
    TOMCAT_VERSION=7.0.109 \
    TOMCAT_HOME=/opt/tomcat \
    CATALINA_HOME=/opt/tomcat \
    CATALINA_OUT=/dev/null

# Download and install tomcat
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends curl && \
    curl -jksSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_HOME} && \
    rm -rf ${TOMCAT_HOME}/webapps/*

# Cleanup
RUN apt-get remove --purge -y curl && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set CATALINA_HOME and add it to PATH (mandatory to run tomcat)
ENV CATALINA_HOME="/opt/tomcat" \
  PATH="$PATH:/opt/tomcat/bin"

# Remove default webapp
RUN rm -fr /opt/tomcat/webapps/*

# Copy mailarchiva WAR to container
COPY files/${MAILARCHIVA_WAR} /opt/tomcat/webapps/ROOT.war

# Unpack the WAR to /var/opt/mailarchiva/tomcat/ROOT and replace PORT to 80
RUN mkdir -p /var/opt/mailarchiva/tomcat/ROOT && \
    unzip $CATALINA_HOME/webapps/ROOT.war -d /var/opt/mailarchiva/tomcat/ROOT && \
    sed -i 's@port=\"8080\" protocol\=\"HTTP\/1.1@port=\"80\" protocol\=\"org.apache.coyote.http11.Http11NioProtocol@g' $CATALINA_HOME/conf/server.xml

# We copy our custom tomcat configuration
# COPY logging.properties ${TOMCAT_HOME}/conf/logging.properties
# COPY server.xml ${TOMCAT_HOME}/conf/server.xml

# By default, the container will launch tomcat on start
CMD ["catalina.sh", "run"]

# (For now) only export PORT 80
EXPOSE 80
