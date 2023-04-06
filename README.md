
# mailarchiva: dockerized - ✉️ + 🐋 = 💕

Run [Mailarchiva, the email archiving, e-discovery, compliance and forensics platform that helps to retain, organize and mine email data](https://www.mailarchiva.com/) in Docker!

## Motivation

The existing projects, which try to run Mailarchiva as a Docker container, are outdated and not working any more. 
I also disliked that they all tried to mimic the traditional on premise installation which is not necessary for a Tomcat application.

That's why I created this project.
# Getting started

## Prerequisites

- A Unix-like operating system: macOS, Linux, BSD.
- ```git``` should be installed (recommended v2.36.1 or higher)
- Docker >= 20.10.14
- Docker-Compose >= v2.5.0

## Installation

1. Clone the repository
   ```sh
   git clone https://github.com/tgoetten/mailarchiva-docker.git
   ```

3. Download latest Mailarchiva WAR file from https://stimulussoft.com/downloads and save it in `files/`
   ```sh
   wget https://stimulussoft.b-cdn.net/mailarchiva_v8.11.56.war -P files
   ```

4. Create a copy of the .env file and adjust it to your needs.
   ```sh
   cp env.sample .env
   ```
5. (optional) Adapt ``docker-compose.yaml if needed

6. Start
   ```sh
   docker-compose up
   ```

## Update
Before you perform the update steps above it is highly recommended to first create a backup.

1. Download latest Mailarchiva WAR file from https://stimulussoft.com/downloads and save it in `files/`
   ```sh
   wget https://stimulussoft.b-cdn.net/mailarchiva_v8.11.56.war -P files
   ```

2. Update `Dockerfile` to use the new .war file when (re-) building the image. To do this, just update the ENV variable with the new .war filenmae
   ```
   ENV MAILARCHIVA_WAR=mailarchiva_v8.11.56.war \
   ...
   ```
3. Build image
   ```
   DOCKER_BUILDKIT=1 docker build -t mailarchiva .
   ```
4. Stop and Re-Start the Container
   ```
   docker-compose stop && docker-compose up -d
   ```

Login to Mailarchiva an make sure the version has changed.
# Todos

- [ ] Automate Download of Mailarchiva WAR file
- [ ] Move from debian image to something smaller (less bloat, quicker build)
- [X] ~~Add instructions to update Mailarchiva to a newer version~~
- [ ] Add support for SSL Certificate using Traefik

# Reference
- https://github.com/bytecast-de/docker-mailarchiva 
- https://github.com/that0n3guy/docker 
- https://github.com/egargale/mailarchiva_alpine