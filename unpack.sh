#!/bin/bash
# created by AtomskJD aka mintru9
# 26-12-2013
# v.024

echo -e "CLEAR SETUP ?[Y/n]: \c"
read SETUP
if [[ $SETUP == "Y" ]] ; then
	chmod 777 -Rf *
	rm -rf *
	echo "PARKING CLEAR"
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
echo "CLEARING old dumps"
if [ $SITE ] ; then
rm -fv dump.sql dump.tar.bz2 htaccess.tar.bz2 .htaccess
else rm -fv dump.sql htaccess.tar.bz2 .htaccess
fi

echo "WGET .haccess"
if wget -q http://surweb-dev.ru/htaccess.tar.bz2 ; then
	echo -e "DOWNLOAD htaccess \t\tSUCCESS"
else echo -e "DOWNLOAD htaccess \t\tFAIL"
	exit
fi

if [ $SITE ] ; then 
	echo "WGET latest dump from $SITE"
	if wget http://$SITE/dump.tar.bz2 ; then
		echo -e "DOWNLOAD DUMP \t\tSUCCESS"
	else 
		echo -e "DOWNLOAD DUMP \t\tFAIL"
		exit
	fi
else
	echo "use old dump"
fi

echo -e "UNPACKING files: "
if tar -xjf htaccess.tar.bz2 ; then
	echo -e "\t\t\t htaccess.tar.bz2 \tSUCCESS"
else echo -e "\t\t\t htaccess.tar.bz2 \tFAIL"
	exit
fi
if tar -xjf dump.tar.bz2 ; then
	echo -e "\t\t\t dump.tar.bz2 \t\tSUCCESS"
else echo -e "\t\t\t dump.tar.bz2 \t\tFAIL"
	exit
fi

echo -e "\vIMPORTING data to database "
if mysql -u$USER -p$PASS $DB < dump.sql ; then
	echo -e "\t\t\tSUCCESS"
else echo -e "\t\t\tFAIL"
	exit
fi

echo -e "\vprepare CONFIG file \c"
chmod 777 sites/default
chmod 777 sites/default/settings.php


if (( $(sed -n "/^ *'database' => '.*'/p" sites/default/settings.php | wc -c) )) ; then
sed -e "s/^ *'database' => '.*'/		'database' => '$DB'/" -e "s/^ *'username' => '.*'/		'username' => '$USER'/" -e "s/^ *'password' => '.*'/		'password' => '$PASS'/" sites/default/settings.php > sites/default/settings.new
echo -e "\t for DRUPAL 7"
fi

#  $db_url = 'mysqli://username:password@localhost/databasename';

if (( $(sed -n "/^\$db_url = 'mysqli:.*';/p" sites/default/settings.php | wc -c) )) ; then
sed -e "s/^\$db_url = 'mysqli:.*';/\$db_url = 'mysqli:\/\/$USER:$PASS@localhost\/$DB';/" sites/default/settings.php > sites/default/settings.new
echo -e "\t for DRUPAL 6"
fi


mv sites/default/settings.php sites/default/settings.old
mv sites/default/settings.new sites/default/settings.php

chmod 444 sites/default/settings.*
chmod 555 sites/default

echo "CLEARING SETUP"
	rm -vf dump.*
	rm -vf htaccess.tar.bz2

echo -e "ALL DONE \t\t $SITE \t\t STAY AWESOME GOTHAM!"