#!/bin/bash
set -e

check_ubuntu_version() {
  if [[ ! -r /etc/os-release ]]; then
    echo -e "ERROR: Not a Linux based system. Use Ubuntu 16.04 Xenial Xerus to run this script."; exit 1
  fi

  . /etc/os-release

  if [[ $NAME != "Ubuntu" && $VERSION_ID != "18.04" ]]; then
    echo -e "ERROR: Wrong Linux distro. Ubuntu 18.04 Bionic needed."; exit 1
  fi
}

update_and_install_os_packages() {
  check_ubuntu_version
  apt-get update
  DEBIAN_FRONTEND='noninteractive' apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade
  DEBIAN_FRONTEND='noninteractive' apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade
  apt-get install apt-transport-https ca-certificates curl vim software-properties-common htop nano sysfsutils -y
  echo 'kernel/mm/transparent_hugepage/enabled = never' >> /etc/sysfs.conf
  echo 'kernel/mm/transparent_hugepage/defrag = never' >> /etc/sysfs.conf
  echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
  echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
}

install_docker() {
  check_ubuntu_version
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'
  apt-get update
  apt-get install docker-ce=18.06.1~ce~3-0~ubuntu -y
}

install_utilities() {
  curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-Linux-x86_64 > /usr/bin/docker-compose
  chmod +x /usr/bin/docker-compose
  curl -L https://github.com/bcicen/ctop/releases/download/v0.6.1/ctop-0.6.1-linux-amd64 > /usr/bin/ctop
  chmod +x /usr/bin/ctop
}


cleanup() {
  check_ubuntu_version
  add-apt-repository --remove 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'
  apt-get autoremove -y
  apt-get clean -y
  apt-get autoclean
  apt-get purge unattended-upgrades -y
  rm -rf /var/lib/apt/lists/*
  rm -rf /var/lib/apt/lists/partial/*
}

kernel_tunning() {
  sysctl -w fs.file-max=2097152 && echo 'fs.file-max=2097152' >> /etc/sysctl.conf
  sysctl -w fs.nr_open=2097152 && echo 'fs.nr_open=2097152' >> /etc/sysctl.conf
  echo 2097152 > /proc/sys/fs/nr_open
  ulimit -n 1048576
  echo 'fs.file-max=2097152' >> /etc/sysctl.conf
  echo '*      soft   nofile      1048576' >> /etc/security/limits.conf
  echo '*      hard   nofile      1048576' >> /etc/security/limits.conf
  sysctl -w net.core.somaxconn=32768 && echo 'net.core.somaxconn=32768' >> /etc/sysctl.conf
  sysctl -w net.ipv4.tcp_max_syn_backlog=16384 && echo 'net.ipv4.tcp_max_syn_backlog=16384' >> /etc/sysctl.conf
  sysctl -w net.core.netdev_max_backlog=16384 && echo 'net.core.netdev_max_backlog=16384' >> /etc/sysctl.conf
  sysctl -w net.core.rmem_default=262144 && echo 'net.core.rmem_default=262144' >> /etc/sysctl.conf
  sysctl -w net.core.wmem_default=262144 && echo 'net.core.wmem_default=262144' >> /etc/sysctl.conf
  sysctl -w net.core.rmem_max=16777216 && echo 'net.core.rmem_max=16777216' >> /etc/sysctl.conf
  sysctl -w net.core.wmem_max=16777216 && echo 'net.core.wmem_max=16777216' >> /etc/sysctl.conf
  sysctl -w net.core.optmem_max=16777216 && echo 'net.core.optmem_max=16777216' >> /etc/sysctl.conf
  sysctl -w net.ipv4.tcp_rmem='1024 4096 16777216' && echo $'net.ipv4.tcp_rmem='1024 4096 16777216'' >> /etc/sysctl.conf
  sysctl -w net.ipv4.tcp_wmem='1024 4096 16777216' && echo $'net.ipv4.tcp_wmem='1024 4096 16777216'' >> /etc/sysctl.conf
  sysctl -w net.nf_conntrack_max=1000000 && echo 'net.nf_conntrack_max=1000000' >> /etc/sysctl.conf
  sysctl -w net.netfilter.nf_conntrack_max=1000000 && echo 'net.netfilter.nf_conntrack_max=1000000' >> /etc/sysctl.conf
  sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=30 && echo 'net.netfilter.nf_conntrack_tcp_timeout_time_wait=30' >> /etc/sysctl.conf
  sysctl -w net.ipv4.tcp_max_tw_buckets=1048576 && echo 'net.ipv4.tcp_max_tw_buckets=1048576' >> /etc/sysctl.conf
  sysctl -w vm.max_map_count=262144 && echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
  echo 'net.ipv4.tcp_fin_timeout = 15' >> /etc/sysctl.conf
#This persists changes for tracking net across reboots
  echo 'nf_conntrack' >> /etc/modules-load.d/modules.conf
  echo " "
  echo "*********************"
  echo "Applying settings to Linux SystemCTL:"
#Apply Config
  sysctl -p
}

printenv
sleep 30
update_and_install_os_packages
install_docker
install_utilities
cleanup
kernel_tunning
mkdir -p /opt/vizix/ /data/dd
rm -f /usr/share/vim/vim80/indent.vim
wget https://s3-eu-west-1.amazonaws.com/mojixdevops/daemon.json -O /etc/docker/daemon.json
service docker restart

### Setting up useful alias for Swarm
echo "alias deploy='docker stack deploy vizix --with-registry-auth -c'" >> ~/.bash_aliases
echo "alias destroy='docker service rm'" >> ~/.bash_aliases && source ~/.bash_aliases

### Usage
echo "You can deploy services like this:  $ deploy services.yaml"
echo "Or destroy services like this:   $ destroy vizix_services"
