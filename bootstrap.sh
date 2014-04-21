#!/usr/bin/env bash

# Update
# --------------------
apt-get update

# Install Apache & PHP
# --------------------
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-apc

# Install 
# --------------------
apt-get install -y vim



# Delete default apache web dir and symlink mounted vagrant dir from host machine
# --------------------
rm -rf /var/www
mkdir /vagrant/httpdocs
ln -fs /vagrant/httpdocs /var/www

# Replace contents of default Apache vhost
# --------------------
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www"
  ServerName localhost
  <Directory "/var/www">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-enabled/000-default

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

cd /vagrant/httpdocs/

if [ ! -f "/vagrant/httpdocs/index.php" ]; then
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

if [ ! -f "/vagrant/httpdocs/app/etc/local.xml" ]; then
    MAGENTO_ETC=$(cat <<EOF
    <?xml version="1.0"?>
    <config>
        <global>
            <install>
                <date><![CDATA[Tue, 31 Dec 2013 10:29:50 +0000]]></date>
            </install>
            <crypt>
                <key><![CDATA[c49db285e6ff11bb01ee598310b84269]]></key>
            </crypt>
            <disable_local_modules>false</disable_local_modules>
            <resources>
                <db>
                    <table_prefix><![CDATA[]]></table_prefix>
                </db>
                <default_setup>
                    <connection>
                        <host><![CDATA[localhost]]></host>
                        <username><![CDATA[magentouser]]></username>
                        <password><![CDATA[password]]></password>
                        <dbname><![CDATA[magentodb]]></dbname>
                        <initStatements><![CDATA[SET NAMES utf8]]></initStatements>
                        <model><![CDATA[mysql4]]></model>
                        <type><![CDATA[pdo_mysql]]></type>
                        <pdoType><![CDATA[]]></pdoType>
                        <active>1</active>
                    </connection>
                </default_setup>
            </resources>
            <session_save><![CDATA[files]]></session_save>
        </global>
        <admin>
            <routers>
                <adminhtml>
                    <args>
                        <frontName><![CDATA[admin]]></frontName>
                    </args>
                </adminhtml>
            </routers>
        </admin>
    </config>
    EOF
    )

    echo "$MAGENTO_ETC" > /vagrant/httpdocs/app/etc/local.xml
fi
