#!/bin/bash
set -e

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" > /etc/apt/sources.list.d/virtualbox.list
apt-get update
apt-get install linux-headers-$(uname -r) unzip dkms unzip virtualbox-5.1 -y
wget -q https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.deb
dpkg -i vagrant_2.0.0_x86_64.deb
wget -q https://releases.hashicorp.com/packer/1.0.4/packer_1.0.4_linux_amd64.zip
unzip packer_1.0.4_linux_amd64.zip
mv packer /usr/local/bin/packer
curl -LOk https://github.com/lmars/packer-post-processor-vagrant-s3/releases/download/1.4.0/packer-post-processor-vagrant-s3-1.4.0-linux-amd64.zip
unzip packer-post-processor-vagrant-s3-1.4.0-linux-amd64.zip
mkdir -p $HOME/.packer.d/plugins
mv packer-post-processor-vagrant-s3 $HOME/.packer.d/plugins/
rm *.deb *.zip
mkdir -p /opt/builder/packer
