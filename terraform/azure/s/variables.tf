#
# Azure Access
#

variable "azure_subscription_id" {
  description = "Enter the Azure Subscription ID."
}

variable "azure_client_id" {
  description = "Enter the Azure Client ID."
}

variable "azure_client_secret" {
  description = "Enter the Azure Client Secret."
}

variable "azure_tenant_id" {
  description = "Enter the Azure Client ID."
}

#
# SSH Access
#
variable "username" {
  description = "Enter the username."
  default     = "vizix"
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "~/.ssh/id_rsa.pub"
}

#
# Instance Details
#

variable "resource_group_name" {
  description = "Enter the Resource Group name. (x.vizixcloud.com)"
}

variable "location" {
  description = "Enter the location."
  default     = "EAST US"
}

variable "mongo_volume_size" {
  description = "Volume size (GB)."
  default     = 100
}

variable "mongo_volume_type" {
  description = "Volume type (Default Premium_LRS)."
  default     = "Premium_LRS"
}
