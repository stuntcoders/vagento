# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "stuntcoders/magento"
  config.vm.box_url = "http://vagento.stuntcoders.com/box/magento.json"

  config.vm.network "private_network", ip: "192.168.33.11"

  config.vm.synced_folder "./", "/vagrant", id: "vagrant-root",
    owner: "www-data", group: "www-data", mount_options: ["dmode=777,fmode=777"]
end

