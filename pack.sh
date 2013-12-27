#!/bin/bash
# @author 	AtomskJD aka mintru9
# version	0.12

settingsDir=sites/default/settings.php
spaceUsed=$(du -sh | cut -f 1)
echo "----------------------------------------------------------------------"
printf "PRE PACKING INFO\nTotal site disk usage\t$spaceUsed\n"
if (( $( ls -l | grep 'bz2$\|sql$' | wc -l) )) ; then
	oldSize=$(du -csh *sql *bz2 | tail -1 | cut -f 1)
	printf "[WARNING!]\nold backup detected\t$oldSize\nCLEAR [Y/n] : "
	read CLEAR
	if [[ $CLEAR = Y ]]; then
		echo -e "CLEARING old dumps\c"
		rm -f *.bz2 *.sql
		echo -e "\t[DONE]"
	else
		echo "[EXIT]"
		exit
	fi
else
	printf "no old backup detected\n"
fi
printf "\n"
echo "----------------------------------------------------------------------"
printf "Choose backup type:\n[ F ] Full backup with DB & FileS\n[ DB ] for db backup\n[ FS ] for files backup\n Type : "
read backupType
	printf "\n"
	echo "----------------------------------------------------------------------"
if [[ $backupType = @(DB|F) ]] ; then

USER=$(grep "^ *'username' => .*',$" $settingsDir | cut -d "'" -f 4)
PASS=$(grep "^ *'password' => .*',$" $settingsDir | cut -d "'" -f 4)
DB=$(grep "^ *'database' => .*',$" $settingsDir | cut -d "'" -f 4)
	echo -e "PACKING DB\c"

	if mysqldump -u$USER -p$PASS $DB > dump.sql ; then
		echo -e "  \t\t[COMPLETE]"
	else
		echo "\n\t\tMYSQLDUMP [FAIL]"
		exit
	fi
fi

if [[ $backupType = @(FS|F) ]] ; then
	printf "\n"
	echo -e "PACKING FILES\c"
	if tar -cjf dump.tar.bz2 * .htaccess ; then
		echo -e "  \t\t[COMPLETE]"
	else
		echo " \t\tTAR [FAIL]"
		exit
	fi
fi
printf "\n"
echo "----------------------------------------------------------------------"
echo -e "go WGET it \t\t[ALL DONE]"