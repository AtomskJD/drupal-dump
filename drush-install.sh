#!/bin/bash
# @author 	AtomskJD aka mintru9
# @version	0.1
## DRUSH INSTALLER

mkdir -p bin install drush

wget -O $HOME/drush/drush.zip https://github.com/drush-ops/drush/archive/6.x.zip
unzip drush/drush.zip -d drush/
rm $HOME/drush/drush.zip
cp $HOME/drush/drush-6.x/* drush/
cp $HOME/drush/drush-6.x/.* drush/
rm -r $HOME/drush/drush-6.x/
chmod u+x $HOME/drush/drush

echo export PATH="/opt/php/5.4/bin:$HOME/bin:$HOME/drush:$PATH" >> .profile
source .profile

echo -e '\033[1;32mInstallation Successful\033[0m'

## INSTALL COMPOSER GLOBALY for 7.x branch only
#curl -sS https://getcomposer.org/installer | php -- --install-dir=$HOME/install
#mv $HOME/install/composer.phar $HOME/bin/composer
