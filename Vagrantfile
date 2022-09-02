# -*- mode: ruby -*-
# vi: set ft=ruby :

$PROVISION = <<-SCRIPT
echo "cd /local-gitlab" >> /home/vagrant/.bashrc

echo "Install basics ..."
amazon-linux-extras install -y docker
usermod -a -G docker vagrant
systemctl enable docker
systemctl start docker

curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

yum install -y git

curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 755 /usr/bin/jq
SCRIPT

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

    config.vm.box = "gbailey/amzn2"
    config.vm.box_version = "20220820.0.0"
    config.vm.synced_folder ".", "/local-gitlab", disabled: false, type: "virtualbox", mount_options: ["dmode=777,fmode=777"]
    config.vm.provision "shell", inline: $PROVISION
    config.vm.network "forwarded_port", guest: 8000, host: 8000
    config.vm.network "forwarded_port", guest: 80, host: 80
    config.vm.network "forwarded_port", guest: 443, host: 443
    config.vm.network "forwarded_port", guest: 8822, host: 8822

    config.vm.provider 'virtualbox' do |v|
        v.memory = 4096
        v.cpus = 2
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
        v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
        v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
    end
end
