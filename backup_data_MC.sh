#!/bin/bash
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

######################## CONFIG START ########################
MAINTAINERLOGIN="yes"
ROOTPW="" # Optional, leave empty if MAINTAINERLOGIN=yes
PRIORITY="0" # "-19" is highest, "19" is lowest
######################### CONFIG END #########################

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DATE=`date +%Y%m%d_%H%M`
TAR=`which tar`
NICE=`which nice`
LOGINLINE="-uroot -p$ROOTPW"
DATEONLY=`date +%Y%m%d_%H00`
ONEHOUROLD=`date '+%Y%m%d_%H00' -d "$end_date-1 hours"`
TWOHOUROLD=`date '+%Y%m%d_%H00' -d "$end_date-2 hours"`
THREEHOUROLD=`date '+%Y%m%d_%H00' -d "$end_date-3 hours"`
FOURHOUROLD=`date '+%Y%m%d_%H00' -d "$end_date-4 hours"`
FIVEHOUROLD=`date '+%Y%m%d_%H00' -d "$end_date-5 hours"`

#FULLBACKUP ARRAY - DELETING BACKUPS older than 5 hours
cd /data/FULLBACKUP
declare -a arrFULLBACKUP=(*);
for dir in "${arrFULLBACKUP[@]}"; do
	echo "$dir";
	if [ $dir == FULL_BACKUP_$ONEHOUROLD ] ; then
			echo "Keeping FULL_BACKUP_$ONEHOUROLD";
	elif [ $dir == FULL_BACKUP_$TWOHOUROLD ] ; then
			echo "Keeping FULL_BACKUP_$TWOHOUROLD";
	
	elif [ $dir == FULL_BACKUP_$THREEHOUROLD ] ; then
			echo "Keeping FULL_BACKUP_$THREEHOUROLD";
	
	elif [ $dir == FULL_BACKUP_$FOURHOUROLD ] ; then
			echo "Keeping FULL_BACKUP_$FOURHOUROLD";
	
	elif [ $dir == FULL_BACKUP_$FIVEHOUROLD ] ; then
			echo "Keeping FULL_BACKUP_$FIVEHOUROLD";
	
	else
		rm -r /data/FULLBACKUP/$dir;
	fi;
done

function revertchanges {
	rm -r /data/FULLBACKUP/FULL_BACKUP_$DATEONLY
}

if [ $MAINTAINERLOGIN == "yes" ] ; then
	echo -en "Testing debian-sys-maintainer login...\t\t\t"
	MAINTLOGIN=`mysqladmin --defaults-file=/etc/mysql/debian.cnf ping 2>&1 | grep "Access denied"`
	if [ ! -z "$MAINTLOGIN" ] ; then
		echo -e "\e[00;31m ERR: Login failed\e[00m"
		exit 1
	fi
	echo -e "\e[00;32m OK\e[00m"
	LOGINLINE="--defaults-file=/etc/mysql/debian.cnf"
else
	echo -en "Testing root login...\t\t\t\t\t"
	MAINTLOGIN=`mysqladmin -uroot -p$ROOTPW ping 2>&1 | grep "Access denied"`
	if [ ! -z "$MAINTLOGIN" ] ; then
		echo -e "\e[00;31m ERR: Login failed\e[00m"
		exit 1
	fi
	echo -e "\e[00;32m OK\e[00m"
fi

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
