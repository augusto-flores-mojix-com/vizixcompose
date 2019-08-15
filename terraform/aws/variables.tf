#
# AWS Access
#

variable "aws_access_key" {
  description = "Enter the AWS access key."
}

variable "aws_secret_key" {
  description = "Enter the AWS secret key."
}

#
# SSH Access
#

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Enter the path to the SSH Private Key to run provisioner."
  default     = "~/.ssh/id_rsa"
}

#
# Instance Details
#

variable "name" {
  description = "Enter the instance name."
}

variable "instances" {
  description = "Enter how many instances should be deployed"
  default     = 1
}

variable "aws_ami" {
  description = "Enter the AWS AMI."
  default     = "ami-cd0f5cb6"       # Ubuntu
}

variable "instance_type" {
  description = "Enter the instance type."

  #default = "t2.micro" # Test Purposes only
  default = "m4.large"
}

variable "root_volume_size" {
  description = "Volume size (GB)."
  default     = 100
}

variable "root_volume_delete" {
  description = "Destroy the volume after termination."
  default     = true
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "ip_whitelist" {
  description = "Array of allowed IPs."
  default     = ["190.181.5.60/32", "147.75.99.67/32", "190.181.5.61/32"]
}

variable "vizix_data_path" {
  description = "Vizix data path."
  default     = "./data"
}

#
# Docker Hub Settings
#

variable "docker_hub_username" {
  description = "Enter the docker hub username"
}

variable "docker_hub_password" {
  description = "Enter the docker hub password"
}

#
# Vizix Settings
#

variable "vizix_ui_version" {
  description = "Enter Vizix UI Version to install"
  default     = "mojix/riot-core-ui:v5.1.3"
}

variable "vizix_services_version" {
  description = "Enter Vizix Services Version to install"
  default     = "mojix/riot-core-services:v5.1.3"
}

variable "vizix_bridges_version" {
  description = "Enter Vizix Bridges Version to install"
  default     = "mojix/riot-core-bridges:v5.1.3"
}

variable "popdb_method" {
  description = "Enter popDB method"
  default     = "platform-core-root"
}
