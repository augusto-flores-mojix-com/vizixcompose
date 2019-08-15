variable "do_token" {}
variable "name" {}

variable "instances" {
  description = "Enter how many instances should be deployed"
  default     = 1
}

variable "region" {
  description = "DigitalOcean Region"
  default     = "nyc3"
}

variable "size" {
  description = "DigitalOcean Droplet Size"
  default     = "8gb"
}

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

variable "vizix_data_path" {
  description = "Vizix data path."
  default     = "./data"
}

variable "public_key" {}
variable "key_path" {}
variable "docker_hub_username" {}
variable "docker_hub_password" {}
