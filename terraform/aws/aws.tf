terraform {
  required_version = "> 0.10.8"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

#
# Resource SSH key
#

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name}-kp"
  public_key = "${file("${var.public_key_path}")}"
}

#
# Network Resources
#

resource "aws_vpc" "vpc_main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.name}-igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a public subnet to launch our load balancers
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc_main.id}"
  cidr_block              = "10.0.1.0/24"            # 10.0.1.0 - 10.0.1.255 (256)
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-subnet"
  }
}

resource "aws_security_group" "security_group" {
  name        = "${var.name}-sg"
  description = "Security group created with Terraform for ${var.name}"
  vpc_id      = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.name}-sg"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = "${var.ip_whitelist}"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MQTT access from anywhere
  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALEBridge access from anywhere
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
# Resource Server
#

resource "aws_instance" "server" {
  ami                    = "${var.aws_ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  subnet_id              = "${aws_subnet.public.id}"
  count                  = "${var.instances}"
  depends_on             = ["aws_key_pair.deployer"]

  tags {
    Name = "${var.name}-${count.index}"
  }

  # root
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete}"
  }

  # Provisioning

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout     = "5m"
  }
  provisioner "file" {
    source      = "${path.module}/../../provision.sh"
    destination = "/tmp/provision.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/provision.sh",
      "cd /tmp",
      "sudo ./provision.sh",
    ]
  }
  provisioner "file" {
    source      = "${path.module}/../../daemon.json"
    destination = "/tmp/daemon.json"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/daemon.json /etc/docker/daemon.json",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl stop docker",
      "sudo rm -rf /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }
  # User permissions doesn't allow to upload directly to /opt/vizix
  provisioner "file" {
    source      = "${path.module}/../../docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }
  provisioner "file" {
    source      = "${path.module}/../../mongoinit.yml"
    destination = "/tmp/mongoinit.yml"
  }
  provisioner "file" {
    source      = "${path.module}/../../envsample"
    destination = "/tmp/envsample"
  }
  provisioner "file" {
    source      = "${path.module}/../../launch.sh"
    destination = "/tmp/launch.sh"
  }
  provisioner "file" {
    source      = "${path.module}/../../Caddyfile"
    destination = "/tmp/Caddyfile"
  }
  provisioner "file" {
    source      = "${path.module}/../../vizix-tools.yml"
    destination = "/tmp/vizix-tools.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv -t /opt/vizix/ /tmp/Caddyfile /tmp/launch.sh /tmp/envsample /tmp/docker-compose.yml /tmp/mongoinit.yml /tmp/vizix-tools.yml",
      "VIZIX_UI_VERSION=${var.vizix_ui_version} VIZIX_SERVICES_VERSION=${var.vizix_services_version} VIZIX_BRIDGES_VERSION=${var.vizix_bridges_version} SERVICES_URL=${self.public_ip} DOCKER_HUB_USERNAME=${var.docker_hub_username} DOCKER_HUB_PASSWORD=${var.docker_hub_password} VIZIX_DATA_PATH=${var.vizix_data_path} sudo -E -S bash /opt/vizix/launch.sh ${var.popdb_method}",
      "sudo rm -f /opt/vizix/launch.sh /tmp/provision.sh",
    ]
  }
}
