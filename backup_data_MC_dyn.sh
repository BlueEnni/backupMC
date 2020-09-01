###################################################
PRIORITY="0" # "-19" is highest, "19" is lowest
TAR=`which tar`
NICE=`which nice`
DATEONLY=`date +%Y%m%d_%H00`
###################################################

#FULLBACKUP ARRAY - DYNAMIC DELETING OLDER BACKUPS
cd /data/FULLBACKUP || exit
declare -a arrEXSISTINGBACKUPS=(*);

echo "$BACKUPCOUNT=BACKUPCOUNT"
declare -a arrWANTEDBACKUPS;
for ((i = 0 ; i < BACKUPCOUNT ; i++)); do
    WANTEDBACKUPNAME=$(date '+%Y%m%d_%H00' -d "-$i hours");
    arrWANTEDBACKUPS=(${arrWANTEDBACKUPS[@]} "FULL_BACKUP_$WANTEDBACKUPNAME");
    echo "Keeping... ${arrWANTEDBACKUPS[$i]}";
done

for backe in "${arrEXSISTINGBACKUPS[@]}"; do
    same=
    for backw in "${arrWANTEDBACKUPS[@]}"; do
    if [ $backe == $backw ] ; then
        same=1;
        break;
    else
        same=0;
    fi;
    done
    # Deleting differences between wanted and existing Backups
    if [ $same == 0 ] ; then
        echo "Deleting... $backe";
        rm -r /data/FULLBACKUP/$backe
    fi;
done

#in case something goes wrong with the backup
function revertchanges {
	rm -r /data/FULLBACKUP/FULL_BACKUP_$DATEONLY
}

#creating a backup
mkdir -p /data/FULLBACKUP/FULL_BACKUP_$DATEONLY

echo -en "Full backup...\t\t\t\t\t\t"
GREPTAR=$($NICE -$PRIORITY $TAR -zcpf /data/FULLBACKUP/FULL_BACKUP_$DATEONLY/fullbackup.tar.gz --directory=/data/ --exclude=backups --exclude=FULLBACKUP . 2>&1)
TAREXC=$?
if [ $TAREXC -eq 2 ] ; then
        echo -e "\e[00;31m FATAL ERR\e[00m"
        echo -e "\n\n\n$GREPTAR"
        revertchanges
        exit 1
fi
if [ $TAREXC -eq 1 ] ; then
        echo -e "\e[00;31m WARNING:\e[00m"
        echo -e "\n\n\n$GREPTAR"
fi
if [ $TAREXC -eq 0 ] ; then
        echo -e "\e[00;32m OK \e[00m"
fi

echo -e "\e[00;32m OK\e[00m"
echo -e "\n\nSuccessfully saved backup to /data/FULLBACKUP/FULL_BACKUP_$DATEONLY"
exit 0