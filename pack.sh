#!/bin/bash
# @author 	AtomskJD aka mintru9
# @version	0.17

if [ $1 ] ; then
	settingsDir=sites/$1/settings.php
else
	settingsDir=sites/default/settings.php
fi

spaceUsed=$(du -sh | cut -f 1)
echo "----------------------------------------------------------------------"
printf "PRE PACKING INFO : \nTotal site disk usage\t$spaceUsed\nSettings path\t\t$settingsDir\n"
if (( $( ls -l | grep 'bz2$\|sql$' | wc -l) )) ; then
	oldSize=$(du -csh *sql *bz2 | tail -1 | cut -f 1)
	printf "[WARNING!]\nold backup detected\t$oldSize\nCLEAR [Y/n] : "
	read CLEAR
	if [[ $CLEAR = Y ]]; then
		echo -e "CLEARING old dumps\c"
		rm -f *.bz2 *.sql
		echo -e "\t[DONE]"
	#else
		#echo "[EXIT]"
		#exit
	fi
else
	printf "no old backup detected\n"
fi

printf "\n"
echo "----------------------------------------------------------------------"
printf "Choose backup type:\n[ F ] Full backup with DB & FileS\n[ DB ] for db backup\n[ FS ] for files backup\n[] Default Full backup\nType : "
read backupType
	printf "\n"
	echo "----------------------------------------------------------------------"
if [[ $backupType = @(DB|F|"") ]] ; then

	if (( $(sed -n "/^ *'database' => '.*'/p" $settingsDir | wc -c) )) ; then
		echo "is drupal 7"
		USER=$(grep "^ *'username' => .*',$" $settingsDir | cut -d "'" -f 4)
		PASS=$(grep "^ *'password' => .*',$" $settingsDir | cut -d "'" -f 4)
		DB=$(grep "^ *'database' => .*',$" $settingsDir | cut -d "'" -f 4)
	fi
	if (( $(sed -n "/^\$db_url = 'mysqli:.*';/p" $settingsDir | wc -c) )) ; then
		echo "is drupal 6"
		USER=$(grep "^\$db_url = 'mysqli:.*';" $settingsDir | cut -c 21- | sed -e "s/@localhost\//:/" -e "s/';//" | cut -d ":" -f 1)
		PASS=$(grep "^\$db_url = 'mysqli:.*';" $settingsDir | cut -c 21- | sed -e "s/@localhost\//:/" -e "s/';//" | cut -d ":" -f 2)
		DB=$(grep "^\$db_url = 'mysqli:.*';" $settingsDir | cut -c 21- | sed -e "s/@localhost\//:/" -e "s/';//" | cut -d ":" -f 3)
	fi

	echo -e "PACKING DB\c"

	if mysqldump -u"$USER" -p"$PASS" "$DB" > dump.sql ; then
		echo -e "  \t\t[COMPLETE]"
	else
		echo "something goes WRONG maybe [PASSWORD]"
		if mysqldump -u"$USER" -p "$DB" > dump.sql ; then
			echo -e "MYSQLDUMP\t\t[COMPLETE]"
		else
			echo -e "\nMYSQLDUMP\t\t[FAIL]"
			exit
		fi
	fi
fi

if [[ $backupType = @(FS|F|"") ]] ; then
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
newSize=$(du -csh *bz2 | tail -1 | cut -f 1)
echo -e "go WGET it $newSize\t\t[ALL DONE]"