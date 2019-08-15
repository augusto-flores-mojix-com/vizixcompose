terraform {
  required_version = "> 0.10.8"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "key" {
  name       = "${var.name}"
  public_key = "${file("${var.public_key}")}"
}

resource "digitalocean_droplet" "server" {
  image    = "ubuntu-16-04-x64"
  name     = "${var.name}-${count.index}"
  region   = "${var.region}"
  size     = "${var.size}"
  count    = "${var.instances}"
  ssh_keys = ["${digitalocean_ssh_key.key.id}"]

  connection {
    type        = "ssh"
    private_key = "${file("${var.key_path}")}"
    user        = "root"
    timeout     = "5m"
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

  provisioner "file" {
    source      = "${path.module}/../../docker-compose.yml"
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
      "VIZIX_UI_VERSION=${var.vizix_ui_version} VIZIX_SERVICES_VERSION=${var.vizix_services_version} VIZIX_BRIDGES_VERSION=${var.vizix_bridges_version} SERVICES_URL=${self.ipv4_address} DOCKER_HUB_USERNAME=${var.docker_hub_username} DOCKER_HUB_PASSWORD=${var.docker_hub_password} VIZIX_DATA_PATH=${var.vizix_data_path} bash /opt/vizix/launch.sh ${var.popdb_method}",
      "rm -rf /opt/vizix/launch.sh",
    ]
  }
}
