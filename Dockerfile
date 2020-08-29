FROM alpine:latest AS build
MAINTAINER BlueEnni

WORKDIR /files

#adding backupscript, entrypointscript, the fixed extrautils2.cfg and the kill-process script to the container
COPY backup_data_MC.sh \
entrypoint.sh \
#creating a FULLBACKUPFOLDER\
&& mkdir ./FULLBACKUP ./

#creating the actual container and copying all the files in to it
FROM alpine:latest AS runtime
COPY --from=build /files /files

WORKDIR /data

RUN apk add --no-cache bash \
&& apk add --update coreutils \
&& rm -rf /var/cache/apk/* \
&& chmod +x /files/backup_data_MC.sh \
&& chmod +x /files/entrypoint.sh

ARG backupdensitycron="0 * * * * "
ARG timezone=Europe/Berlin
ENV BACKUPDENSITYCRON=$backupdensitycron
ENV TIMEZONE=$timezone

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Entrypoint with java optimisations
ENTRYPOINT /files/entrypoint.sh