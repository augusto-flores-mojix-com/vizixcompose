terraform {
  required_version = "> 0.10.8"
}

provider "packet" {
  auth_token = "${var.packet_api_key}"
}

resource "packet_ssh_key" "ssh_key" {
  name       = "${var.server_name}-ssh"
  public_key = "${file("${var.public_key_path}")}"
}

resource "packet_device" "server" {
  hostname         = "${var.server_name}-${count.index}"
  plan             = "${var.plan}"
  facility         = "${var.facility}"
  operating_system = "ubuntu_16_04"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  count            = "${var.instances}"

  connection {
    type        = "ssh"
    private_key = "${file("${var.private_key_path}")}"
    user        = "root"
    timeout     = "30m"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../provision.sh",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/../../daemon.json"
    destination = "/etc/docker/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl stop docker",
      "rm -rf /var/lib/docker",
      "systemctl start docker",
    ]
  }

  // Downgrade to 4.10 Kernel
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../../downgradeKernel.sh",
    ]
  }

  // Reboot from API
  provisioner "remote-exec" {
    inline = [
      "curl -X POST https://api.packet.net/devices/${self.id}/actions -H 'content-type: multipart/form-data' -H 'x-auth-token: ${var.packet_api_key}' -F type=reboot",
    ]
  }

  // Wait until reboot
  provisioner "local-exec" {
    command = "echo 'Restart in progress...' && sleep 30"
  }

  provisioner "file" {
    source      = "${path.module}/../../docker-compose-kafka.yml"
    destination = "/opt/vizix/docker-compose.yml"
  }

  provisioner "file" {
    source      = "${path.module}/../../envsample"
    destination = "/opt/vizix/envsample"
  }

  provisioner "file" {
    source      = "${path.module}/../../launch.sh"
    destination = "/opt/vizix/launch.sh"
  }

  provisioner "file" {
    source      = "${path.module}/../../Caddyfile"
    destination = "/opt/vizix/Caddyfile"
  }

  provisioner "file" {
    source      = "${path.module}/../../vizix-tools.yml"
    destination = "/opt/vizix/vizix-tools.yml"
  }

  provisioner "file" {
    source      = "${path.module}/../../mongoinit.yml"
    destination = "/opt/vizix/mongoinit.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "VIZIX_TOOLS_VERSION=${var.vizix_tools_version} VIZIX_UI_VERSION=${var.vizix_ui_version} VIZIX_SERVICES_VERSION=${var.vizix_services_version} VIZIX_BRIDGES_VERSION=${var.vizix_bridges_version} SERVICES_URL=${self.network.0.address} DOCKER_HUB_USERNAME=${var.docker_hub_username} DOCKER_HUB_PASSWORD=${var.docker_hub_password} VIZIX_DATA_PATH=${var.vizix_data_path} bash /opt/vizix/launch.sh ${var.popdb_method}",
      "rm -rf /opt/vizix/launch.sh",
    ]
  }
}
