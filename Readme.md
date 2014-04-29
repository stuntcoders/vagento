Goal
------------------
Setup Magento 1.8.1.0 with 1.6.1.0 sample data as starting point for development.


Make sure you have following installed on your system:
-------------------
 * Ruby: [https://www.ruby-lang.org/](https://www.ruby-lang.org/)
 * Virtual Box: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
 * Vagrant: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

Follow instructions:
-------------------
 * Make a project directory `mkdir projectname && cd projectname`
 * Run `curl http://stuntcoders.com/vagento | bash` in your terminal
 * Follow instructions from output to setup and install Magento


Once Magento and Vagrant are installed you can use following credentials:
-------------------
|       | User        | Password |
| ----- | ------------| -------- |
| MySQL | magentouser | password |
| Admin | admin       | m123123  |


To ssh to your virtual box use `vagrant ssh`, and go to `cd /vagrant`.
This is where your Magento is installed.