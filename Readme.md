Goal
------------------
Setup Magento with sample data as starting point for development.

Made for Magento 1.8.1.0 and 1.6.1.0 sample data.

Setup Instructions
-------------------
 * Make sure you have Ruby installed
 * Install Virtual Box: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
 * Install Vagrant for your platform: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)
 * Fork this project
 * Clone it to your computer, and enter the folder

```bash
# Run the configuration script with custom options
bash vmsetup.sh -p projectname -i 192.168.33.21

# Additional parameter can be applied
# -d domainname.local (default will be "$PROJECTNAME.local")
# 
# sudo bash vmsetup.sh -p projectname -d domainname.local -i 192.168.33.21
```

Credentials:

|       | User        | Password |
| ----- | ------------| -------- |
| MySQL | magentouser | password |
| Admin | admin       | m123123  |
