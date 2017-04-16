Vagento (Vagrant & Magento)
------------------
The goal of this project is to use the least possible number of steps to set new project with [Vagrant](http://vagrantup.com/) and [Magento](http://magento.com/).

This project will help you setup Vagrant, install Magento 1.9 with 1.9.2.4 sample data and set local environment on your Mac (not tested on Linux) as starting point for development.


Make sure you have following installed
-------------------
 * Virtual Box: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
 * Vagrant: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

Once you have everything installed, setting up your Magento sample project will be a piece of cake.

Use simple setup steps
-------------------
 * Make a project directory `mkdir projectname && cd projectname`
 * Run `curl http://vagento.stuntcoders.com/ | bash` in your terminal
 * Follow instructions from output to setup Vagrant and install Magento


Magento and Vagrant are set
-------------------
You can now use following data to access database or Magento administration:

|       | User        | Password |
| ----- | ------------| -------- |
| MySQL | magentouser | password |
| Admin | admin       | m123123  |


To ssh to your virtual box use `vagrant ssh`, and go to `cd /vagrant`. This is where your Magento is installed.
