#!/bin/bash
# @author 	AtomskJD aka mintru9
# @version	0.28

echo -e "CLEAR SETUP ?[Y/n]: \c"
read SETUP
if [[ $SETUP == @("Y"|"") ]] ; then
	chmod -Rf 777 *
	rm -rf *
	echo "PARKING CLEAN"
else
	if (( $(ls -1 | wc -l) )) ; then
		WRN=$(ls -1 | wc -l)
		echo -e "WARNING PARKING HAS $WRN objects"
	else
		echo "EASY SETUP no files in PARKING"
	fi
fi
# get params
if [ $1 ]; 
	then USER=$1
else 
	echo -e "set DB USER: \c"
	read USER
fi
if [ $2 ]; 
	then PASS=$2
else 
	echo -e "set PASSWORD: \c"
	read PASS
fi
if [ $3 ]; 
	then DB=$3
else 
	echo -e "set DB NAME: \c"
	read DB
fi
if [ $4 ]; 
	then SITE=$4
else 
	echo -e "set WGET site address (if empty use current backup): \c"
	read SITE
fi

# make magic
#echo "CLEARING old dumps"
if [ $SITE ] ; then
rm -fv dump.sql dump.tar.bz2 htaccess.tar.bz2 .htaccess
else rm -fv dump.sql htaccess.tar.bz2 .htaccess
fi
printf "\n"
echo "----------------------------------------------------------------------"
printf "DOWNLOAD COMPONENTS\n"
#echo "WGET .haccess"
if wget -q http://surweb-dev.ru/htaccess.tar.bz2 ; then
	echo -e "download htaccess\t\t[SUCCESS]"
else echo -e "download htaccess\t\t[FAIL]"
	exit
fi

if [ $SITE ] ; then 
	echo -e "WGET dump from\t$SITE\n"
	if wget http://$SITE/dump.tar.bz2 ; then
		echo -e "download dump.tar.bz2\t\t[SUCCESS]"
	else 
		echo -e "download dump.tar.bz2\t\t[FAIL]"
		exit
	fi
else
	echo "use old dump"
fi

printf "\n"
echo "----------------------------------------------------------------------"
echo -e "UNPACKING FILES : "
if tar -xjf htaccess.tar.bz2 ; then
	echo -e "extract htaccess.tar.bz2\t[SUCCESS]"
else echo -e "extract htaccess.tar.bz2\t[FAIL]"
	exit
fi
if tar -xjf dump.tar.bz2 ; then
	echo -e "extract dump.tar.bz2\t\t[SUCCESS]"
else echo -e "extract dump.tar.bz2\t\t[FAIL]"
	exit
fi

printf "\n"
echo "----------------------------------------------------------------------"
echo -e "IMPORT DATABASE : "
if mysql -u$USER -p$PASS $DB < dump.sql ; then
	echo -e "database import\t\t\t[SUCCESS]"
else echo -e "database import\t\t\t[FAIL]"
	exit
fi

printf "\n"
echo "----------------------------------------------------------------------"
echo -e "PREPARE CONFIG\c"
chmod 777 sites/default
chmod 777 sites/default/settings.*


if (( $(sed -n "/^\s*'database' => '.*'/p" sites/default/settings.php | wc -c) )) ; then
sed -e "s/^\s*'database' => '.*'/		'database' => '$DB'/" -e "s/^\s*'username' => '.*'/		'username' => '$USER'/" -e "s/^\s*'password' => '.*'/		'password' => '$PASS'/" sites/default/settings.php > sites/default/settings.new
echo -e "\t\t\tfor DRUPAL 7"
fi

#  $db_url = 'mysqli://username:password@localhost/databasename';

if (( $(sed -n "/^\$db_url = 'mysqli:.*';/p" sites/default/settings.php | wc -c) )) ; then
sed -e "s/^\$db_url = 'mysqli:.*';/\$db_url = 'mysqli:\/\/$USER:$PASS@localhost\/$DB';/" sites/default/settings.php > sites/default/settings.new
echo -e "\t\t\tfor DRUPAL 6"
fi


mv sites/default/settings.php sites/default/settings.old
mv sites/default/settings.new sites/default/settings.php

chmod 444 sites/default/settings.*
chmod 555 sites/default

echo -e "CLEARING SETUP\c"
	rm -f dump.*
	rm -f htaccess.tar.bz2
echo -e "\t\t\t[SUCCESS]"

printf "\n"
echo "----------------------------------------------------------------------"
echo -e "$SITE\t\t\t[ALL DONE]"