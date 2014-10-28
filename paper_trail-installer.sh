#!/bin/bash
# @author 	AtomskJDev
# @version	0.1
## LOG pusher INSTALLER

mkdir -p bin install drush

wget -O $HOME/install/remote_syslog.tar.gz "https://github.com/papertrail/remote_syslog2/releases/download/v0.13/remote_syslog_linux_386.tar.gz"
tar xzf $HOME/install/remote_syslog*.tar.gz -C $HOME/install
cp $HOME/install/remote_syslog/* $HOME/bin

rm $HOME/install/remote_syslog*

echo "mail.add_x_header = On" >> $HOME/php-bin/php.ini
echo "mail.log = $HOME/logs/mail.log" >> $HOME/php-bin/php.ini

#cp $HOME/bin/example_config.yml $HOME/bin/remote_syslog_conf.yml
# set YOUR instance values

sed -e "s/port:.*$/port: 28248/" -e "s/host:.*$/host: logs2.papertrailapp.com/" -e "s/^\s*- locallog.txt/  - \$HOME\/logs\/*.error.log\n  - \$HOME\/logs\/mail.log/" $HOME/bin/example_config.yml > $HOME/bin/remote_syslog_conf.yml


echo -e '\033[1;32mInstallation Successful\033[0m'