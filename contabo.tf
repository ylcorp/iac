locals {
  contabo_extra_fields = zipmap(
    data.bitwarden_item_login.contabo_credential.field.*.name,
    data.bitwarden_item_login.contabo_credential.field.*.text
  )
}

output "contabo_extra_fields" {
  value     = local.contabo_extra_fields
  sensitive = true
}
# Configure your Contabo API credentials
provider "contabo" {
  oauth2_client_id     = lookup(local.contabo_extra_fields, "clientId")
  oauth2_client_secret = lookup(local.contabo_extra_fields, "clientSecret")
  oauth2_user          = data.bitwarden_item_login.contabo_credential.username
  oauth2_pass          = data.bitwarden_item_login.contabo_credential.password
}

variable "contabo_instance_id" {
  #TODO: Why dont use local-exec with cntb tool with credential information above to get the instance id
  default = "201497816"
}

data "contabo_instance" "main_instance" {
  id = var.contabo_instance_id
}

locals {
  contabo_instance_ipv4 = data.contabo_instance.main_instance.ip_config[0].v4[0].ip
}

output "ipv4" {
  value = local.contabo_instance_ipv4
}

resource "null_resource" "install_app_main_contabo" {
  # Specify triggers to force the execution of the provisioner
  triggers = {
    instance_id = data.contabo_instance.main_instance.id
  }
  # Use the remote-exec provisioner to execute commands on the EC2 instance
  provisioner "remote-exec" {
    # Specify connection details to the EC2 instance
    connection {
      type        = "ssh"
      host        = local.contabo_instance_ipv4
      user        = "root"                    # or your desired SSH user
      private_key = file("~/.ssh/id_ed25519") # Path to your private key
    }

    # Specify commands to be executed remotely
    inline = [
      "ls"
    ]
  }
}

output "bw_contabo_credential_client_id" {
  value     = lookup(local.contabo_extra_fields, "clientId")
  sensitive = true
}

output "bw_contabo_credential_client_user" {
  value     = data.bitwarden_item_login.contabo_credential.username
  sensitive = true
}
