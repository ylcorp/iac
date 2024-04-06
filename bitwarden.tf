variable "bw_client_id" {
  type        = string
  description = "bitwarden client_id"
}

variable "bw_client_secret" {
  type        = string
  description = "bitwarden client_secret"
}

variable "bw_client_email" {
  type        = string
  description = "bitwarden email"
}

variable "bw_client_pwd" {
  type        = string
  description = "bitwarden master pwd"
}

provider "bitwarden" {
  client_id       = var.bw_client_id
  client_secret   = var.bw_client_secret
  master_password = var.bw_client_pwd
  email           = var.bw_client_email
}

data "bitwarden_item_login" "contabo_credential" {
  id = "8748aa71-f781-46dd-9a26-b149007803d3"
}
