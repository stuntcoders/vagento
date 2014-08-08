#!/bin/bash

source Vagentofile

while getopts p:d:i:c:e: option
do
    case "${option}"
    in
        p) PROJECT=${OPTARG};;
        d) DOMAIN=${OPTARG};;
        i) IP=${OPTARG};;
        c) CURRENCY=${OPTARG};;
        e) EMAIL=${OPTARG};;
    esac
done

if [ ! -f ProjectReadme.md ]; then
    ALREADY_CONFIGURED="y"
fi

if [ -z "$DOMAIN" ]; then
    DOMAIN="$PROJECT.local"
fi

# If project is already configured don't change any domain settings or IP addresses
if [ "$ALREADY_CONFIGURED" == "n" ]; then
    echo "Project: $PROJECT with domain: $DOMAIN on IP: $IP is being created..."

	echo 'Replacing default values in config...'
	ruby -pi -e "gsub(/stuntgento.local/, '$DOMAIN')" Vagrantfile
	ruby -pi -e "gsub(/192.168.33.11/, '$IP')" Vagrantfile

	ruby -pi -e "gsub(/stuntgento.local/, '$DOMAIN')" ProjectReadme.md
	ruby -pi -e "gsub(/192.168.33.11/, '$IP')" ProjectReadme.md

	ruby -pi -e "gsub(/stuntgento/, '$PROJECT')" Vagentofile
	ruby -pi -e "gsub(/stuntgento.local/, '$DOMAIN')" Vagentofile
	ruby -pi -e "gsub(/DOMAIN=\"\"/, 'DOMAIN=\"$DOMAIN\"')" Vagentofile
	ruby -pi -e "gsub(/192.168.33.11/, '$IP')" Vagentofile
	ruby -pi -e "gsub(/NOK/, '$CURRENCY')" Vagentofile
	ruby -pi -e "gsub(/hello@stuntcoders.com/, '$EMAIL')" Vagentofile
	ruby -pi -e "gsub(/ALREADY_CONFIGURED=\"n\"/, 'ALREADY_CONFIGURED=\"y\"')" Vagentofile

	#Remove Readme.md and rename ProjectReadme.md to Readme.md
	rm -rf Readme.md
	mv ProjectReadme.md Readme.md
fi

# Check if IP already exists in /etc/hosts
if grep -Fxq "$IP" /etc/hosts; then
	echo "------------------------------"
	echo '$IP is already written in /etc/hosts... skipping this part...'
	echo "Please check if line '$IP $DOMAIN' exists"
	echo "------------------------------"
else
	echo "------------------------------"
	echo 'Writing to /etc/hosts...'
	sudo bash -c "echo '$IP $DOMAIN' >> /etc/hosts"
	echo "------------------------------"
fi

vagrant up

echo "------------------------------"
echo "Your setup should be ready. Visit: http://$DOMAIN/ to see the results!"
echo "If not... run vagrant destroy and then vagrant up again."
echo "------------------------------"

if [ "$ALREADY_CONFIGURED" == "n" ]; then
	#check if in git repo
	if [ ! -d .git ]; then
		git init
		git add .
		git commit -am 'Vagento project has been initialized...'
	fi

	echo 'Other team members can now join and use your environment settings. Happy coding! :)'
fi
