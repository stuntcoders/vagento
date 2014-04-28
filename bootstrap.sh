#!/usr/bin/env bash

source /vagrant/config.sh

# Update
# --------------------
apt-get update

# Install Apache & PHP
# --------------------
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-apc

# Install tools StuntCoders needs
# --------------------
apt-get install -y vim

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

mysql -u root -e "CREATE DATABASE IF NOT EXISTS magentodb"
mysql -u root -e "GRANT ALL PRIVILEGES ON magentodb.* TO 'magentouser'@'localhost' IDENTIFIED BY 'password'"
mysql -u root -e "FLUSH PRIVILEGES"

cd /vagrant/

if [ ! -f "/vagrant/index.php" ]; then
    wget http://www.magentocommerce.com/downloads/assets/1.8.1.0/magento-1.8.1.0.tar.gz
    tar -zxvf magento-1.8.1.0.tar.gz
    wget http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz
    tar -zxvf magento-sample-data-1.6.1.0.tar.gz
    mv magento-sample-data-1.6.1.0/media/* magento/media/
    mv magento-sample-data-1.6.1.0/magento_sample_data_for_1.6.1.0.sql magento/data.sql
    mv magento/* magento/.htaccess* .
    chmod -R o+w media var
    mysql -h localhost -u magentouser -ppassword magentodb < data.sql
    chmod o+w var var/.htaccess app/etc
    rm -rf magento/ magento-sample-data-1.6.1.0/ magento-1.8.1.0.tar.gz magento-sample-data-1.6.1.0.tar.gz data.sql
fi

if [ ! -f "/vagrant/app/etc/local.xml" ]; then
php -f /vagrant/install.php -- \
--license_agreement_accepted "yes" \
--locale "en_US" \
--timezone "Europe/Budapest" \
--default_currency "NOK" \
--db_host "localhost" \
--db_name "magentodb" \
--db_user "magentouser" \
--db_pass "password" \
--url "$DOMAIN" \
--use_rewrites "yes" \
--use_secure "no" \
--secure_base_url "" \
--use_secure_admin "no" \
--admin_firstname "Dejan" \
--admin_lastname "Jacimovic" \
--admin_email "dejan.jacimovic@gmail.com" \
--admin_username "admin" \
--admin_password "m123123"
fi

# Add SASS watch on every boot
# --------------------
SASS=$(cat <<EOF
#! /bin/sh
cd /vagrant/skin/frontend/$PROJECT/default/
sass --watch sass:css
EOF
)

sudo bash -c "echo '$SASS' > /etc/rc0.d/sasswatch.sh"
