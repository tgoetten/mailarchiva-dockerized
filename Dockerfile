# Use the specified base image
FROM tomcat:10.1-jdk21-temurin-jammy

# (further) set environment variables
ENV MAILARCHIVA_WAR=mailarchiva-9.0.36.war
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
WORKDIR $CATALINA_HOME

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y wget \
  curl \
  unzip

# Cleanup
RUN apt-get remove --purge -y curl && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove the default web applications
RUN rm -rf ${CATALINA_HOME}/webapps/*

# Ensure that MAILARCHIVA_WAR is provided as a build argument
ARG MAILARCHIVA_WAR
# Copy the MailArchiva WAR file to the container
COPY files/${MAILARCHIVA_WAR} ${CATALINA_HOME}/webapps/ROOT.war
RUN \
    sed -i 's@port=\"8080\" protocol\=\"HTTP\/1.1@port=\"80\" protocol\=\"org.apache.coyote.http11.Http11NioProtocol@g' $CATALINA_HOME/conf/server.xml

# By default, the container will launch tomcat on start
CMD ["catalina.sh", "run"]

# (For now) only export PORT 80
EXPOSE 80