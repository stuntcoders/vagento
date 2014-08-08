#!/bin/bash

## BEGIN OUTPUT METHODS

# Echo in bold font if stdout is a terminal
ISTTY=0; if [ -t 1 ]; then ISTTY=1; fi
bold ()      { if [ $ISTTY -eq 1 ]; then tput bold;     fi; }
red ()       { if [ $ISTTY -eq 1 ]; then tput setaf 1;  fi; }
green ()     { if [ $ISTTY -eq 1 ]; then tput setaf 2;  fi; }
yellow ()    { if [ $ISTTY -eq 1 ]; then tput setaf 3;  fi; }
cyan ()      { if [ $ISTTY -eq 1 ]; then tput setaf 6;  fi; }
normalize () { if [ $ISTTY -eq 1 ]; then tput sgr0; fi; }

echo_bold ()      { echo -e "$(bold)$1$(normalize)"; }
echo_underline () { echo -e "\033[4m$1$(normalize)"; }
echo_color ()     { echo -e "$2$1$(normalize)"; }

function echo_title {

    title=$1
    length=$((${#title}+30))

    echo ""
    for i in {1..3}
    do
        if [ $i = 2 ]; then

            echo_bold "-------------- $title --------------"

        else
            COUNTER=0
            output=""
            while [  $COUNTER -lt $length ]; do
                output="$output-"
                COUNTER=$(($COUNTER + 1))
            done
            echo_bold $output
        fi
    done
    printf "\n\n"

}

pager=${PAGER:-$(which pager &> /dev/null)}
if [ -z "$pager" ]; then
    pager=less
fi
## END OUTPUT METHODS



BASE_DIR=$(pwd)
SETTINGS_FILE="Vagentofile"

# Controller is the first, action is the second argument
# --------------------
CONTROLLER=$1
ACTION=$2

CONFIG_LOADED=0

if [ -f "$BASE_DIR/$SETTINGS_FILE" ]; then
    source $BASE_DIR/$SETTINGS_FILE
    CONFIG_LOADED=1
fi

# Options are loaded
# --------------------
while getopts c: option
do
    case "${option}"
    in
        c) CLEANDB=${OPTARG};;
    esac
done

THEME_DIR="$BASE_DIR/skin/frontend/$PROJECT/default"

VERSION="0.8.1"
SCRIPT=${0##*/}

USAGE="\

Vagento bash (v$VERSION) by $(green)StuntCoders doo$(normalize)

__     __                     _
\ \   / /_ _  __ _  ___ _ __ | |_ ___
 \ \ / / _' |/ _' |/ _ \ '_ \| __/ _ \\
  \ V / (_| | (_| |  __/ | | | || (_) |
   \_/ \__,_|\__, |\___|_| |_|\__\___/
             |___/

Global Commands:
  $SCRIPT <command> [<options>]
----------------------------------------------------------------
  $(green)help$(normalize)                      List commands with short description
  $(green)setup$(normalize)                     Set configuration for the project

  $(green)install magento$(normalize)           Install Magento in working directory
  $(green)install magento clean$(normalize)     Install Magento on clean database
  $(green)install magento sample$(normalize)    Load sample data for Magento
  $(green)install wp$(normalize)                Install fresh WordPress
  $(green)install grunt$(normalize)             Set Grunt tasks for defined theme

  $(green)magento list modules$(normalize)      Lists all installed Mageto modules
  $(green)magento list web-settings$(normalize) Lists all DB configuration

"

LIST="\

Vagento list of commands:

"

##################################
#### DEFINE ALL THE FUNCTIONS ####

### PROBLEM SOLVING METHODS

function setup_configuration {

    clear
    echo_title "PROJECT SETUP"

    echo "Please, enter project name in small caps: "
    read PROJECT

    echo "Please, domain name (if left empty, default will be $PROJECT.local): "
    read DOMAIN
    if [ -z "$DOMAIN" ]; then
        DOMAIN="$PROJECT.local"
    fi

    echo "What is your available IP address for '$PROJECT': "
    read IP

    echo "Please enter WordPress folder relative path (side, seite, site, sajt, etc...): "
    read SITE_FOLDER

    echo "Please enter default currency: "
    read CURRENCY

    echo "Please enter default locale (en_EN, de_DE, nb_NO, etc...): "
    read LOCALE

    CONF=$(cat <<EOF
#!/bin/bash

PROJECT="$PROJECT"
DOMAIN="$DOMAIN"
IP="$IP"
HOSTS="y"
SITE_FOLDER="$SITE_FOLDER"
CURRENCY="$CURRENCY"
LOCALE="$LOCALE"
ALREADY_CONFIGURED="y"
EOF
)

    sudo bash -c "echo '$CONF' > $BASE_DIR/$SETTINGS_FILE"
}

function quick_setup_configuration {

    CONF=$(cat <<EOF
#!/bin/bash

PROJECT="$1"
DOMAIN="$2"
IP="$3"
HOSTS="y"
SITE_FOLDER="$4"
CURRENCY="$5"
LOCALE="$6"
ALREADY_CONFIGURED="y"
EOF
)

    sudo bash -c "echo '$CONF' > $BASE_DIR/$SETTINGS_FILE"

}

function install_magento {

    cd $BASE_DIR

    mysql -u root -e "CREATE DATABASE IF NOT EXISTS magentodb"
    mysql -u root -e "GRANT ALL PRIVILEGES ON magentodb.* TO 'magentouser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"

#    n98-magerun.phar install --dbHost="localhost" --dbUser="magentouser" --dbPass="password" --dbName="magentodb1" \
#     --installSampleData=yes --useDefaultConfigParams=yes --magentoVersionByName="magento-ce-1.8.1.0" \
#     --installationFolder="" --baseUrl="http://$DOMAIN/" --timezone "Europe/Budapest" \
#     --defaultCurrency="$CURRENCY" --locale "$LOCALE"
#
#    #n98-magerun.phar admin:user:create [username] [email] [password] [firstname] [lastname]
#    n98-magerun.phar admin:user:create vagento dejan@stuntcoders.com m123123 Dejan Jacimovic
#    n98-magerun.phar admin:user:change-password admin m123123
#

    if [ ! -f "$BASE_DIR/index.php" ]; then
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

    if [ ! -f $(get_base_dir "/app/etc/local.xml") ]; then
        php -f /vagrant/install.php -- \
--license_agreement_accepted "yes" \
--locale "$LOCALE" \
--timezone "Europe/Budapest" \
--default_currency "$CURRENCY" \
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

    n98-magerun.phar config:set web/seo/use_rewrites 1
}

function install_magento_sample {

    cd $BASE_DIR

    # Drop and create DB
    mysql -u root -e "DROP DATABASE magentodb"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS magentodb"
    mysql -u root -e "GRANT ALL PRIVILEGES ON magentodb.* TO 'magentouser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"

    # Import DB sample data
    if [ ! -f "magento_sample_data_for_1.6.1.0.sql" ]; then
        wget http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz
        tar -zxvf magento-sample-data-1.6.1.0.tar.gz

        mv magento-sample-data-1.6.1.0/media/* media/
        mv magento-sample-data-1.6.1.0/magento_sample_data_for_1.6.1.0.sql magento_sample_data_for_1.6.1.0.sql

        rm -rf magento/ magento-sample-data-1.6.1.0/ magento-1.8.1.0.tar.gz magento-sample-data-1.6.1.0.tar.gz
    fi

    mysql -h localhost -u magentouser -ppassword magentodb < magento_sample_data_for_1.6.1.0.sql

    # Set administrator's new password
    mysql -u root -e "UPDATE magentodb.admin_user SET password=CONCAT(MD5('qXm123123'), ':qX') WHERE username='admin';"


    # Set project theme
    mysql -u root -e "DELETE FROM magentodb.core_config_data WHERE path='design/package/name';"
    mysql -u root -e "DELETE FROM magentodb.core_config_data WHERE path='design/theme/locale';"
    mysql -u root -e "DELETE FROM magentodb.core_config_data WHERE path='design/theme/default';"

    mysql -u root -e "INSERT INTO magentodb.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'design/package/name', '$PROJECT');"
    mysql -u root -e "INSERT INTO magentodb.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'design/theme/locale', '$PROJECT');"
    mysql -u root -e "INSERT INTO magentodb.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'design/theme/default', '$PROJECT');"

    # Configure basic settings
    mysql -u root -e "DELETE FROM magentodb.core_config_data WHERE path='web/unsecure/base_url';"
    mysql -u root -e "DELETE FROM magentodb.core_config_data WHERE path='web/secure/base_url';"

    mysql -u root -e "INSERT INTO magentodb.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'web/unsecure/base_url', 'http://$DOMAIN/');"
    mysql -u root -e "INSERT INTO magentodb.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'web/secure/base_url', 'http://$DOMAIN/');"

    # Set new homepage
    CONTENT='{{block type="catalog/product_list_random" category_id="18" template="catalog/product/list.phtml"}}'
    mysql -u root -e "UPDATE magentodb.cms_page SET content='$CONTENT', root_template='one_column' WHERE identifier='home';"

    # Set all notifications as read
    mysql -u root -e "UPDATE magentodb.adminnotification_inbox SET is_read=1 WHERE 1=1;"
}

function install_wordpress {

    cd $BASE_DIR

    # Install WordPress (with wp-cli)
    # --------------------
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS wpdb"
    mysql -u root -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"

    if [ ! -f "$BASE_DIR/$SITE_FOLDER/wp-config.php" ]; then
        curl -L https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > wp-cli.phar
        chmod +x wp-cli.phar & sudo mv wp-cli.phar /usr/bin/wp

        if [ ! -d /vagrant/side ]; then
            mkdir /vagrant/side
        fi

        cd /vagrant/side
        wp core download
        wp core config --dbname=wpdb --dbuser=wpuser --dbpass=password --extra-php <<PHP
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
PHP
       wp core install --url="http://$DOMAIN/side"  --title="$PROJECT" --admin_user="admin" --admin_password="m123123" --admin_email="dejan@stuntcoders.com"
    fi
}

function install_grunt_in_theme {

    # Setup Gruntfile and package.json if they are not already set
    # --------------------
    sudo rm -rf $THEME_DIR/Gruntfile.js
    if [ ! -f "$THEME_DIR/Gruntfile.js" ]; then
        GRUNTFILE=$(cat <<EOF
module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON("package.json"),
        sass: {
            dist: {
                files: {
                    "$THEME_DIR/css/styles.css" : "$THEME_DIR/sass/styles.scss"
                }
            }
        },
        watch: {
            livereload: {
                options: {
                    livereload: true
                },
                files: [
                    "$THEME_DIR/css/styles.css"
                ]
            },
            css: {
                files: "$THEME_DIR/sass/styles.scss",
                tasks: ["sass"]
            }
        }
    });
    grunt.loadNpmTasks("grunt-contrib-sass");
    grunt.loadNpmTasks("grunt-contrib-watch");
    grunt.registerTask("default", ["watch"]);
}
EOF
)
        sudo bash -c "echo '$GRUNTFILE' > $THEME_DIR/Gruntfile.js"
    fi

    # Setup Gruntfile and package.json if they are not already set
    # --------------------
    rm -rf $THEME_DIR/package.json
    if [ ! -f "$THEME_DIR/package.json" ]; then
        PACKAGEJSON=$(cat <<EOF
{
  "name": "$PROJECT",
  "version": "0.0.1",
  "devDependencies": {
    "grunt": "^0.4.5",
    "grunt-contrib-sass": "^0.7.3",
    "grunt-contrib-watch": "^0.6.1"
  }
}
EOF
)

        bash -c "echo '$PACKAGEJSON' > $THEME_DIR/package.json"
    fi

    # Install npm packages
    # --------------------
    cd $THEME_DIR
    sudo npm install

    # Add GRUNT on every boot
    # --------------------
    GRUNT=$(cat <<EOF
#!/usr/bin/env bash

### BEGIN INIT INFO
# Provides:          grunf
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start grunt at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

SCRIPTNAME=/etc/init.d/$NAME

case "\$1" in
    start)
        grunt --base $THEME_DIR --gruntfile $THEME_DIR/Gruntfile.js
        ;;
    *)
        echo "Usage: $0 {status|start|stop|restart}"
        exit 1
esac
EOF
)

    export SASS_PATH=$THEME_DIR

    # Save grunt settings in Von Grunf file
    sudo rm -rf /etc/init.d/grunf
    sudo bash -c "echo '$GRUNT' > /etc/init.d/grunf"
    sudo update-rc.d -f grunf remove
    sudo update-rc.d grunf defaults
    sudo chmod +x /etc/init.d/grunf
}

#### END OF ALL FUNCTIONS ####
##############################



#### PROCESS THE REQUEST ####

if [ "$CONTROLLER" = "--help" -o "$CONTROLLER" = "" -o "$CONTROLLER" = "help" ]; then

    clear; echo -e "$USAGE"; exit 0

fi

if [ "$CONTROLLER" = "setup" ]; then

    if [ -z "$3" ]; then
        setup_configuration
    else
        quick_setup_configuration $2 $3 $4 $5 $6 $7
    fi

fi

if [ "$CONTROLLER" = "install" ]; then

    if [ "$CONFIG_LOADED" = "0" ]; then
        setup_configuration
    fi

    # Install Magento
    # --------------------
    if [ "$ACTION" = "magento" ]; then

        clear

        if [ "$3" == "clean" ]; then
            echo "Cleaning Magento database..."
            mysql -u root -e "DROP DATABASE magentodb"
            rm -rf /vagrant/app/etc/local.xml
        fi

        if [ "$3" == "sample" ]; then
            echo "Installing Magento sample data..."
            install_magento_sample
        else
            echo "Installing fresh Magento..."
            install_magento
        fi

    fi

    # Install WordPress
    # --------------------
    if [ "$ACTION" = "wordpress" -o "$ACTION" = "wp" ]; then

        clear
        echo "Installing WordPress..."
        install_wordpress

    fi

    # Install Grunt
    # --------------------
    if [ "$ACTION" = "grunt" ]; then

        clear
        echo "Setting up grunt in theme folder..."
        install_grunt_in_theme

        echo_title "GRUNT"

        echo "To run grunt with live reload put following code in your theme"
        echo_bold "page/html/head.php:"
        printf "\n"
        echo_bold "<?php echo \"<script src='//{\$_SERVER['HTTP_HOST']}:35729/livereload.js'></script>\";"
        echo ""
        echo "...and run following command in your terminal:"
        echo_bold "service grunf start"
        echo ""

    fi

fi

if [ "$CONTROLLER" = "magento" ]; then

    if [ "$ACTION" = "list" ]; then

        case $3 in
            "modules")
                n98-magerun.phar sys:modules:list
                ;;
            "web-settings")
                n98-magerun.phar config:get web/
                ;;
        esac
    fi

fi
