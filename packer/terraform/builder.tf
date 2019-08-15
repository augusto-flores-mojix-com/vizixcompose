terraform {
  required_version = "> 0.11.0"
}

variable "packet_api_key" {}
variable "packet_project_id" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vizix_version" {}
variable "docker_hub_username" {}
variable "docker_hub_password" {}

provider "packet" {
  auth_token = "${var.packet_api_key}"
}

resource "tls_private_key" "builder" {
  algorithm = "RSA"
}

resource "packet_ssh_key" "builder" {
  name       = "vizix-in-a-box-temporal-key"
  public_key = "${tls_private_key.builder.public_key_openssh}"
}

resource "packet_device" "builder" {
  operating_system = "ubuntu_16_04"
  hostname         = "vizix-box-builder"
  facility         = "sjc1"
  plan             = "baremetal_1"
  billing_cycle    = "hourly"
  project_id       = "${var.packet_project_id}"

  connection {
    type        = "ssh"
    private_key = "${tls_private_key.builder.private_key_pem}"
    user        = "root"
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    scripts = ["./provision.sh"]
  }

  provisioner "file" {
    source      = "../http"
    destination = "/opt/builder/packer/http"
  }

  provisioner "file" {
    source      = "../vagrantfile.tpl"
    destination = "/opt/builder/packer/vagrantfile.tpl"
  }

  provisioner "file" {
    source      = "../vizix.json"
    destination = "/opt/builder/packer/vizix.json"
  }

  provisioner "file" {
    source      = "../../launch.sh"
    destination = "/opt/builder/launch.sh"
  }

  provisioner "file" {
    source      = "../../envsample"
    destination = "/opt/builder/envsample"
  }

  provisioner "file" {
    source      = "../../docker-compose.yml"
    destination = "/opt/builder/docker-compose.yml"
  }

  provisioner "file" {
    source      = "../../daemon.json"
    destination = "/opt/builder/daemon.json"
  }

  provisioner "file" {
    source      = "../../provision.sh"
    destination = "/opt/builder/provision.sh"
  }

  provisioner "file" {
    source      = "../../Caddyfile"
    destination = "/opt/builder/Caddyfile"
  }

  provisioner "file" {
    source      = "../../mongoinit.yml"
    destination = "/opt/builder/mongoinit.yml"
  }

  provisioner "file" {
    source      = "../../vizix-tools.yml"
    destination = "/opt/builder/vizix-tools.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/builder/packer/",
      "AWS_ACCESS_KEY=${var.aws_access_key} AWS_SECRET_KEY=${var.aws_secret_key} packer validate -var vizix_version=${var.vizix_version} -var docker_hub_username=${var.docker_hub_username} -var docker_hub_password=${var.docker_hub_password} vizix.json",
      "AWS_ACCESS_KEY=${var.aws_access_key} AWS_SECRET_KEY=${var.aws_secret_key} packer build -var vizix_version=${var.vizix_version} -var docker_hub_username=${var.docker_hub_username} -var docker_hub_password=${var.docker_hub_password} vizix.json",
    ]
  }
}
