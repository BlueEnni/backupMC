#!/bin/bash
#creating a FULLBACKUPFOLDER
mkdir ./FULLBACKUP
#add timezone
apk add tzdata
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
apk del tzdata
#Add the backupcount
touch /files/backup_data_MC_new.sh
echo "#!/bin/bash" > /files/backup_data_MC_new.sh
echo "BACKUPCOUNT="$BACKUPCOUNT"" >> /files/backup_data_MC_new.sh
cat /files/backup_data_MC_dyn.sh >> /files/backup_data_MC_new.sh
chmod +x /files/backup_data_MC_new.sh
# Add the cronjobs
echo "${BACKUPDENSITYCRON}/files/backup_data_MC_new.sh" > /etc/crontabs/root
# Start the crond process
crond -f
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start crond: $status"
  exit $status
fi