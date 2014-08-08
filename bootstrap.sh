#!/usr/bin/env bash

source /vagrant/Vagentofile

# Update
# --------------------
apt-get update

# Install Apache & PHP
# --------------------
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-apc

# Install postfix
# --------------------
debconf-set-selections <<< "postfix postfix/mailname string $DOMAIN"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -y postfix

# Install vim, curl, git
# --------------------
apt-get install -y vim git curl wget

# Install nodejs (with npm), and then grunt and yeoman
# --------------------
apt-get install python-software-properties
apt-add-repository ppa:chris-lea/node.js
apt-get install -y nodejs

npm install -g grunt-cli grunt-init yo

# Composer
# --------------------
curl -sS https://getcomposer.org/installer | php
sudo chmod +x ./composer.phar
mv composer.phar /usr/local/bin/composer

# Magerun
# --------------------
wget https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar
sudo chmod +x ./n98-magerun.phar
sudo cp ./n98-magerun.phar /usr/local/bin/

# Modman
# --------------------
wget https://raw.githubusercontent.com/colinmollenhour/modman/master/modman
sudo chmod +x ./modman
sudo cp ./modman /usr/local/bin/

# Vagento
# --------------------
wget http://vagento.stuntcoders.com/vagento.sh
sudo chmod +x ./vagento.sh
sudo mv ./vagento.sh /usr/local/bin/vagento

# WP cli
# --------------------
curl -L https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/bin/wp

# Update Gem and install bourbon
# --------------------
gem update --system
gem install bourbon


# Delete default apache web dir and symlink mounted vagrant dir from host machine
# --------------------
rm -rf /var/www
if [ ! -d "/vagrant/httpdocs" ]; then
  mkdir /vagrant/httpdocs
fi
ln -fs /vagrant /var/www

# Replace contents of default Apache vhost
# --------------------
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/vagrant"
  ServerName localhost
  <Directory "/vagrant">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-enabled/000-default
sudo sh -c 'echo "ServerName localhost" >> /etc/apache2/conf.d/name'
sudo bash -c "echo '127.0.0.1 $DOMAIN' >> /etc/hosts"

a2enmod rewrite
service apache2 restart

# Mysql
# --------------------
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive
# Install MySQL quietly
apt-get -q -y install mysql-server-5.5

cd /vagrant/

vagento setup $PROJECT $DOMAIN $IP $SITE_FOLDER $CURRENCY $LOCALE
vagento install magento
vagento install magento sample
vagento install wp
vagento install grunt
