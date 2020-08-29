#!/bin/bash
#creating a FULLBACKUPFOLDER
mkdir ./FULLBACKUP
#add timezone
apk add tzdata
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
apk del tzdata
# Add the cronjobs
echo "${BACKUPDENSITYCRON}/files/backup_data_MC.sh" > /etc/crontabs/root
# Start the crond process
crond -f
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start crond: $status"
  exit $status
fi