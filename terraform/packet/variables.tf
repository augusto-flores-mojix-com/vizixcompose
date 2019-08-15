variable "packet_api_key" {}
variable "server_name" {}

variable "instances" {
  description = "Enter how many instances should be deployed"
  default     = 1
}

variable "plan" {
  description = "Packet server plan"
  default     = "baremetal_0"
}

variable "facility" {
  description = "Packet facility code"
  default     = "ewr1"
}

variable "popdb_method" {
  description = "Enter popDB method"
  default     = "platform-core-root"
}

variable "vizix_data_path" {
  description = "Vizix data path."
  default     = "./data"
}

variable "vizix_ui_version" {
  description = "Enter Vizix UI Version to install"
  default     = "mojix/riot-core-ui:v5.1.3"
}

variable "vizix_services_version" {
  description = "Enter Vizix Services Version to install"
  default     = "mojix/riot-core-services:v5.1.3"
}

variable "vizix_tools_version" {
  description = "Enter Vizix Tools Version to install"
  default     = "mojix/vizix-tools:release_5.1.5"
}

variable "vizix_bridges_version" {
  description = "Enter Vizix Bridges Version to install"
  default     = "mojix/riot-core-bridges:v5.1.3"
}

variable "project_id" {}

variable "public_key_path" {}
variable "private_key_path" {}

variable "docker_hub_username" {}
variable "docker_hub_password" {}
