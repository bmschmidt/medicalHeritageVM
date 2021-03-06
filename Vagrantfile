# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/wily64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    # v.cpus = 2
  end
  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  
  # RStudio
  config.vm.network "forwarded_port", guest: 8787, host: 8787
  config.vm.network "forwarded_port", guest: 80, host: 8007
  config.vm.network "forwarded_port", guest: 8888, host: 8888

  # add dummy to avoid "Could not retrieve fact fqdn"
  # config.vm.hostname = "vagrant.example.com"

  
  
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/vagrant"
  config.vm.synced_folder "texts", "/texts"
  config.vm.synced_folder "images", "/images"

  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision :puppet,
                      #    :options => ["--verbose", "--debug"] do |puppet|
                      #    :options => ["--debug"] do |puppet|
                      :options => [] do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "/"
    puppet.module_path = "puppet/modules"

  end

  config.vm.provision "shell", inline: "/bin/bash /vagrant/FreshInstallationScript/no-input-needed.sh"

end
