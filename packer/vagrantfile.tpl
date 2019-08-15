Vagrant.configure("2") do |config|
  config.ssh.shell = "bash"
  config.ssh.username = "vizix"
  config.ssh.password = "vizix"
  config.vm.hostname = "vizix"
  config.vm.network "private_network", ip: "192.168.50.10"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.cpus = 2
  end

  config.vm.provision "shell" do |s|
    s.inline = 'sed -i "1s/.*/SERVICES_URL=$1/" /opt/vizix/.env && cd /opt/vizix/ && docker-compose up -d ui'
    s.args   = ["192.168.50.10"]
  end

  config.ssh.insert_key = false
end
