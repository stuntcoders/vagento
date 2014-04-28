Goal
------------------
Create a Vagrant configuration that offers ability to install different versions of Magento with minimum effort.

Tested for 1.8.1.0 and 1.6.1.0 sample data.

Setup Instructions
-------------------
 * Install Virtual Box: https://www.virtualbox.org/wiki/Downloads
 * Install Vagrant for your platform: https://www.vagrantup.com/downloads.html
 * Fork this project
 * Clone it to your computer, and enter the folder

```bash
# Run the configuration script with custom options
bash vmsetup.sh -p projectname -i 192.168.33.21

# Additional parameters can be applied
# -d domainname.local (default will be "$PROJECTNAME.local")
# -h no (prevent editing of /etc/hosts, default is "y")
# 
# sudo bash vmsetup.sh -p projectname -d domainname.local -i 192.168.33.21 -h no
```

Credentials:

|       | User        | Password |
| ----- | ------------| -------- |
| MySQL | magentouser | password |
| Admin | admin       | m123123  |
