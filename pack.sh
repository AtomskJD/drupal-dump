#!/bin/bash

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

rm -fv dump.sql dump.tar.bz2
echo "CLEARING old dumps"

echo -e "PACKING DB\c"
if mysqldump -u$USER -p$PASS $DB > dump.sql ; then
	echo -e "  \t\tSUCCESS"
else
	echo " \t\tFAIL MYSQLDUMP"
	exit
fi

echo -e "PACKING FILES\c"
if tar -cjf dump.tar.bz2 * .htaccess ; then
	echo -e "  \t\tDUMP.tar.bz2 COMPLETE"
else
	echo " \t\tTAR FAIL"
	exit
fi
echo -e "go WGET it \t\tALLONS-Y!"