# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.56.11"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # we will try to autodetect this path.
  # However, if we cannot or you have a special one you may pass it like:
  # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
  # or an URL:
  # config.vbguest.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"
  # or relative to the Vagrantfile:
  # config.vbguest.iso_path = File.expand_path("../relative/path/to/VBoxGuestAdditions.iso", __FILE__)

  # set auto_update to false, if you do NOT want to check the correct
  # additions version when booting this machine
  # config.vbguest.auto_update = false

  # do NOT download the iso file from a webserver
  #config.vbguest.no_remote = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.post_up_message = "SOP lab"
  config.vm.host_name = "sop-lab"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = "2048"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  local_config_file = File.join(File.dirname(__FILE__), "Vagrantfile.local")
  if File.exists?(local_config_file) then
    eval(File.read(local_config_file), binding, "Vagrantfile.local")
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    set -o errexit
    sudo apt-get update

    # Install python
    sudo apt-get install python -y

	# Install Pandoc
    # PANDOC_VERSION=1.19.2.1
    curl -LR -O -s https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb
    sudo dpkg --install pandoc-1.19.2.1-1-amd64.deb
    git clone https://github.com/jgm/pandocfilters
    cd pandocfilters
    sudo python setup.py install
    cd

    # Install ZIP
    sudo apt-get install zip -y

	# Install R
	#sudo apt-get install -y libssl-dev libcurl4-openssl-dev
    #sudo apt-get install -y r-base r-base-dev
	#sudo Rscript /vagrant/stats/prepare_r_env.R

	# Install tshark
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tshark
	# Clone ws_dissector_helper
	git clone https://github.com/prontog/ws_dissector_helper
	mkdir ~/.wireshark
	ln -s /vagrant/network/init.lua ~/.wireshark/

    # Add necessary env vars:
    echo Updating .bashrc
    echo "source /vagrant/env.sh" >> ~/.bashrc
  SHELL
end
