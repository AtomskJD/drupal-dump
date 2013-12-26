#!/bin/bash
# @author 	AtomskJD aka mintru9
# version	0.10

settingsDir=sites/default/settings.php

USER=$(grep "^ *'username' => .*',$" $settingsDir | cut -d "'" -f 4)
PASS=$(grep "^ *'password' => .*',$" $settingsDir | cut -d "'" -f 4)
DB=$(grep "^ *'database' => .*',$" $settingsDir | cut -d "'" -f 4)

printf "Choose backup type:\n[ F ] Full backup with DB & FileS\n[ DB ] for db backup\n[ FS ] for files backup"
read backupType

rm dump.sql dump.tar.bz2
echo "CLEARING old dumps"
	
if [[ $backupType = @(DB | F) ]]; then
	echo "----------------------------------------------------------------------"
	echo -e "PACKING DB\c"

	if mysqldump -u$USER -p$PASS $DB > dump.sql ; then
		echo -e "  \t\t[COMPLETE]"
	else
		echo "\n\t\tMYSQLDUMP [FAIL]"
		exit
	fi
fi

if [[ $backupType = @(FS | F) ]]; then
	echo "----------------------------------------------------------------------"
	echo -e "PACKING FILES\c"
	if tar -cjf dump.tar.bz2 * .htaccess ; then
		echo -e "  \t\t[COMPLETE]"
	else
		echo " \t\tTAR [FAIL]"
		exit
	fi
fi

echo -e "go WGET it \t\t [ALL DONE]"