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

VERSION="0.8.2"
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
--------------------------------------------------------------------------
  $(green)help$(normalize)                                List commands with short description
  $(green)setup$(normalize)                               Set configuration for the project
  $(green)update$(normalize)                              Updates Vagento to latest version
  $(green)version-check$(normalize)                       Check if latest version is used

  $(green)install magento$(normalize)                     Install Magento in working directory
  $(green)install magento clean$(normalize)               Install Magento on clean database
  $(green)install magento sample$(normalize)              Load sample data for Magento
  $(green)install wp$(normalize)                          Install fresh WordPress
  $(green)install wp clean-db$(normalize)                 Install WordPress clean database
  $(green)install hooks$(normalize)                       Install git commit hooks

  $(green)wp list plugins$(normalize)                     Lists all installed WP plugins
  $(green)wp list users$(normalize)                       Lists all WP users
  $(green)wp update$(normalize)                           Update WordPress
  $(green)wp db-chdomain old.com new$(normalize)          Replace old domain name with new one
  $(green)wp db-load name.sql$(normalize)                 Remove old and reload new DB
  $(green)wp db-export name.sql$(normalize)               Export DB
  $(green)wp set wp-config$(normalize)                    Set default wp-config
  $(green)wp set admin$(normalize)                        Set default user to admin/sc123123

  $(green)mage module clone$(normalize)                   Clone magento module
  $(green)mage list modules$(normalize)                   Lists all installed Mageto modules
  $(green)mage list web-settings$(normalize)              Lists all DB configuration
  $(green)mage db-chdomain name.sql old new$(normalize)   Replace old domain with new in file
  $(green)mage db-load name.sql$(normalize)               Remove old and reload a new DB
  $(green)mage db-export name.sql$(normalize)             Export DB
  $(green)mage set admin$(normalize)                      Change password for admin to sc123123
  $(green)mage set local-xml$(normalize)                  Set local.xml file for sample config
  $(green)mage set htaccess$(normalize)                   Set .htaccess
  $(green)mage clear-cache$(normalize)                    Clear Magento cache

"

LIST="\

Vagento list of commands:

"

##################################
#### DEFINE ALL THE FUNCTIONS ####

### PROBLEM SOLVING METHODS

function setup_configuration {
    clear

    echo "Please, enter project name in small caps: "
    read PROJECT

    echo "Please, domain name (if left empty, default will be $PROJECT.local): "
    read DOMAIN
    if [ -z "$DOMAIN" ]; then
        DOMAIN="$PROJECT.local"
    fi

    echo "What is your available IP address for '$PROJECT' (192.168.x.x): "
    read IP

    echo "Please enter WordPress folder relative path (side, seite, site, sajt, etc...): "
    read SITE_FOLDER

    echo "Please enter default currency: "
    read CURRENCY

    echo "Please enter default locale (en_US, de_DE, nb_NO, etc...): "
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

    sudo apt-get install unzip

    mysql -u root -e "CREATE DATABASE IF NOT EXISTS magento"
    mysql -u root -e "GRANT ALL PRIVILEGES ON magento.* TO 'vagentouser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"

    if [ ! -f "$BASE_DIR/index.php" ]; then
        wget https://github.com/OpenMage/magento-mirror/archive/magento-1.9.zip
        unzip magento-1.9.zip
        mv magento-mirror-magento-1.9/* .
        rm -rf magento-mirror-magento-1.9/
    fi

    if [ ! -f "$BASE_DIR/app/etc/local.xml" ]; then
        php -f /vagrant/install.php -- \
--license_agreement_accepted "yes" \
--locale "$LOCALE" \
--timezone "Europe/Belgrade" \
--default_currency "$CURRENCY" \
--db_host "localhost" \
--db_name "magento" \
--db_user "vagentouser" \
--db_pass "password" \
--url "$DOMAIN" \
--use_rewrites "yes" \
--use_secure "no" \
--secure_base_url "" \
--use_secure_admin "no" \
--admin_firstname "Dejan" \
--admin_lastname "Jacimovic" \
--admin_email "hello@example.com" \
--admin_username "stuntcoders" \
--admin_password "sc123123" \
--skip_url_validation "yes"
    fi

    install_magento_defaults
}

function clean_magento_db {
    # Drop and create DB
    mysql -u root -e "DROP DATABASE magento"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS magento"
    mysql -u root -e "GRANT ALL PRIVILEGES ON magento.* TO 'vagentouser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"
}

function install_magento_defaults {
    # Set administrator's new password
    mysql -u root -e "UPDATE magento.admin_user SET password=CONCAT(MD5('qXsc123123'), ':qX') WHERE username='admin';"

    # Set project theme
    mysql -u root -e "DELETE FROM magento.core_config_data WHERE path='design/package/name';"
    mysql -u root -e "DELETE FROM magento.core_config_data WHERE path='design/theme/locale';"
    mysql -u root -e "DELETE FROM magento.core_config_data WHERE path='design/theme/default';"

    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'design/package/name', '$PROJECT');"
    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'design/theme/locale', '$PROJECT');"
    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'design/theme/default', '$PROJECT');"
    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'web/cookie/cookie_path', '/');"

    # Configure basic settings
    mysql -u root -e "DELETE FROM magento.core_config_data WHERE path='web/unsecure/base_url';"
    mysql -u root -e "DELETE FROM magento.core_config_data WHERE path='web/secure/base_url';"

    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'web/unsecure/base_url', 'http://$DOMAIN/');"
    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'web/secure/base_url', 'http://$DOMAIN/');"

    # Remove suffix from products and categories
    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'catalog/seo/product_url_suffix', '');"
    mysql -u root -e "REPLACE INTO magento.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'catalog/seo/category_url_suffix', '');"

    # Set all notifications as read
    mysql -u root -e "UPDATE magento.adminnotification_inbox SET is_read=1 WHERE 1=1;"
}

function clean_wp_db {
    mysql -u root -e "DROP DATABASE IF EXISTS wpdb"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS wpdb"
    mysql -u root -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"
}

function set_wordpress_config {
    cd "$BASE_DIR/$SITE_FOLDER"

    wp core config --dbname=wpdb --dbuser=wpuser --dbpass=password --extra-php <<PHP
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
PHP
}

function install_wordpress_clean_db {
    cd $BASE_DIR

    mysql -u root -e "DROP DATABASE IF EXISTS wpdb"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS wpdb"
    mysql -u root -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"

    cd "$BASE_DIR/$SITE_FOLDER"
    set_wordpress_config
    wp core install --url="http://$DOMAIN/$SITE_FOLDER"  --title="$PROJECT" --admin_user="admin" --admin_password="sc123123" --admin_email="hello@example.com"

    # Delete base plugins
    wp plugin delete hello
    wp plugin delete hello-dolly

    # Cleanup
    wp widget delete search-2
    wp post delete 1
    wp comment delete 1
    wp rewrite structure "/%postname%/"
    wp rewrite flush
}

function install_wordpress {
    cd $BASE_DIR

    # Install WordPress (with wp-cli)
    # --------------------
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS wpdb"
    mysql -u root -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost' IDENTIFIED BY 'password'"
    mysql -u root -e "FLUSH PRIVILEGES"

    if [ ! -f "$BASE_DIR/$SITE_FOLDER/wp-config.php" ]; then

        if [ ! -d "$BASE_DIR/$SITE_FOLDER/" ]; then
            mkdir "$BASE_DIR/$SITE_FOLDER/"
        fi

        cd "$BASE_DIR/$SITE_FOLDER/"
        wp core download
        install_wordpress_clean_db

        cd $BASE_DIR
    fi
}

function clone_module() {
    sudo rm -r vagentotemp
    sudo mkdir vagentotemp
    sudo git clone "$1" vagentotemp
}

function deploy_module {
    cd vagentotemp

    sudo rsync -rv --exclude 'Readme.md' --exclude 'modman' --exclude '.*' ./ ../

    cd ../
}

function check_for_update() {
    curl --silent https://raw.githubusercontent.com/stuntcoders/vagento/master/vagento.sh > __vagentoupdate.temp

    if ! diff $0 "__vagentoupdate.temp" > /dev/null ; then
        echo "$(red)New Vagento version available$(normalize)"
        echo "Run \"$(green)vagento update$(normalize)\" to update to latest version"
    else
        echo "You have latest version of vagento"
    fi

    sudo rm -r __vagentoupdate.temp
}

function self_update() {
    sudo rm -f vagento.sh /usr/local/bin/vagento
    wget https://raw.githubusercontent.com/stuntcoders/vagento/master/vagento.sh
    sudo chmod +x ./vagento.sh
    sudo mv ./vagento.sh /usr/local/bin/vagento

    echo "$(green)Vagento updated to latest version! :)$(normalize)"
    exit 0;
}

function check_for_update_and_update() {
    curl --silent https://raw.githubusercontent.com/stuntcoders/vagento/master/vagento.sh > __vagentoupdate.temp

       if ! diff $0 "__vagentoupdate.temp" > /dev/null ; then
           echo "$(red)New Vagento version available$(normalize)"
           echo "$(yellow) Automatic update started"
           self_update

       else
           echo "You have latest version of vagento"
       fi

       sudo rm -r __vagentoupdate.temp
}

#### END OF ALL FUNCTIONS ####
##############################


#### PROCESS THE REQUEST ####

if [ "$CONTROLLER" = "--help" -o "$CONTROLLER" = "" -o "$CONTROLLER" = "help" ]; then

    clear; echo -e "$USAGE";

fi

if [ ! "$CONTROLLER" = "--help" -a ! "$CONTROLLER" = "" -a ! "$CONTROLLER" = "help" ]; then

    check_for_update_and_update

fi

if [ "$CONTROLLER" = "setup" ]; then

    if [ -z "$3" ]; then
        setup_configuration
    else
        quick_setup_configuration $2 $3 $4 $5 $6 $7
    fi

fi

if [ "$CONTROLLER" = "update" ]; then

    self_update

fi

if [ "$CONTROLLER" = "version-check" ]; then

    check_for_update

fi

if [ "$CONTROLLER" = "install" ]; then

    if [ "$CONFIG_LOADED" = "0" ]; then
        setup_configuration
    fi

    # Install Magento
    # --------------------
    if [ "$ACTION" = "magento" ]; then

        clear

        case $3 in
            "clean")
                echo "Cleaning Magento database..."
                mysql -u root -e "DROP DATABASE magento"
                rm -rf $BASE_DIR"/app/etc/local.xml"
                install_magento
                ;;
            "sample")
                echo "Installing Magento sample data..."
                echo "Not available currently."
                ;;
            *)
                echo "Installing fresh Magento..."
                install_magento
                ;;
        esac

    fi

    # Install WordPress
    # --------------------
    if [ "$ACTION" = "wordpress" -o "$ACTION" = "wp" ]; then

        clear
        case $3 in
            "clean-db")
                echo "Installing clean WordPress database..."
                install_wordpress_clean_db
                ;;
            *)
                echo "Installing WordPress..."
                install_wordpress
                ;;
        esac
    fi

    # Install Git commit hooks
    # --------------------
    if [ "$ACTION" = "hooks" ]; then

        git clone -q --depth 1 https://github.com/stuntcoders/stunt_mage_pre_commit_hooks.git git_hooks
        cd git_hooks && ./install
        cd ../ && rm -rf git_hooks

        echo_bold "Git commit hooks installed"
    fi
fi

if [ "$CONTROLLER" = "wp" ]; then

    if [ "$ACTION" = "list" ]; then

        case $3 in
            "plugins")
                wp plugin list --path="$BASE_DIR/$SITE_FOLDER"
                ;;
            "users")
                wp user list --path="$BASE_DIR/$SITE_FOLDER"
                ;;
        esac
    fi

    if [ "$ACTION" = "update" ]; then

        wp core update --path="$BASE_DIR/$SITE_FOLDER"
        wp plugin update --all --path="$BASE_DIR/$SITE_FOLDER"
        wp theme update --all --path="$BASE_DIR/$SITE_FOLDER"

    fi

    if [ "$ACTION" = "db-chdomain" ]; then

        wp search-replace $3 $4 --path="$BASE_DIR/$SITE_FOLDER"

    fi

    if [ "$ACTION" = "db-load" ]; then

        if [ -f $3 ]; then
            # Load database from file
            clean_wp_db
            wp db import $3 --path="$BASE_DIR/$SITE_FOLDER"
        fi

    fi

    if [ "$ACTION" = "db-export" ]; then
        wp db export $3 --path="$BASE_DIR/$SITE_FOLDER"
    fi

    if [ "$ACTION" = "set" ]; then

        case $3 in
            "admin")
                mysql -u root -e "UPDATE wpdb.`wp_users` SET `user_pass` = MD5('sc123123') WHERE `wp_users`.`user_login` = "admin";;"
                ;;
            "wp-config")
                set_wordpress_config
                ;;
        esac
    fi
fi

if [ "$CONTROLLER" = "mage" ]; then

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

    if [ "$ACTION" = "module" ]; then

        case $3 in
            "clone")
                clear
                clone_module "$4"
                echo "$(green)Deploying module$(normalize)"
                deploy_module
                sudo rm -r vagentotemp
                echo "$(green)Module deployed$(normalize)"
                ;;
        esac
    fi

    if [ "$ACTION" = "db-chdomain" ]; then

        sed -i "" "s/$4/$5/g" $3

    fi

    if [ "$ACTION" = "db-load" ]; then

        if [ -f $3 ]; then
            # Load database from file
            clean_magento_db
            mysql -h localhost -u vagentouser -ppassword magento < $3
        fi

    fi

    if [ "$ACTION" = "db-export" ]; then
        mysqldump --opt --routines --no-data --skip-triggers  -uroot magento > $3
        mysqldump --opt --no-create-info --skip-triggers  -uroot magento >> $3
        mysqldump --opt --no-create-info --no-data --triggers  -uroot magento >> $3
    fi

    if [ "$ACTION" = "set" ]; then

        case $3 in
            "admin")
                mysql -u root -e "UPDATE magento.admin_user SET password=CONCAT(MD5('qXsc123123'), ':qX') WHERE username='admin';"
                ;;
            "local-xml")
                n98-magerun.phar local-config:generate localhost vagentouser password magento files admin
                ;;
            "htaccess")
                rm -f .htaccess
                wget https://raw.githubusercontent.com/magento/magento2/2.2-develop/.htaccess
                ;;
        esac
    fi

    if [ "$ACTION" = "clear-cache" ]; then
        n98-magerun.phar cache:clean
    fi
fi
