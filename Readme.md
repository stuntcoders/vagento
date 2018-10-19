Vagento (Vagrant & Magento)
------------------
The goal of this project is to use the least possible number of steps to set new project with [Vagrant](http://vagrantup.com/) and [Magento](http://magento.com/) or [WordPress](https://wordpress.org/).

This project will help you setup Vagrant, install Magento 1.9 or the latest WordPress, and set local environment on your machine as starting point for development.


Make sure you have following installed
-------------------
 * Virtual Box: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
 * Vagrant: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

Once you have everything installed, setting up your Magento or WordPress project will be a piece of cake.

Use simple setup steps
-------------------
 * Make a project directory `mkdir projectname && cd projectname`
 * Run `curl https://raw.githubusercontent.com/stuntcoders/vagento/master/vagento.sh | bash` in your terminal
 * Follow instructions from output to setup Vagrant and install Magento


Magento and Vagrant are set
-------------------
You can now use following data to access database or Magento administration:

|       | User        | Password |
| ----- | ----------- | -------- |
| MySQL | vagentouser | password |
| Admin | admin       | sc123123 |


To ssh to your virtual box use `vagrant ssh`, and go to `cd /vagrant`. This is where your Magento is installed.
