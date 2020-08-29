#!/bin/bash
#copy files to mounted folder /data
shopt -s extglob
mv /files/!(entrypoint.sh && backup_data_MC.sh) /data
rm -R /files/!(entrypoint.sh)
#add timezone
apk add tzdata
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
apk del tzdata
# Add the cronjobs
echo "${BACKUPDENSITYCRON}/files/backup_data_MC.sh" > /etc/crontabs/root
# Start the crond process
crond
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start crond: $status"
  exit $status
fi