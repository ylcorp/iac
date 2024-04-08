locals {
  contabo_secret_arn = "arn:aws:secretsmanager:ap-southeast-2:975050295711:secret:contabo_api_key-YoxM3t"
}

data "aws_secretsmanager_secret" "contabo_secret_meta" {
  arn = local.contabo_secret_arn
}

data "aws_secretsmanager_secret_version" "contabo_secret_version" {
  secret_id = data.aws_secretsmanager_secret.contabo_secret_meta.id
}

locals {
  contabo_secret_value_parse = jsondecode(data.aws_secretsmanager_secret_version.contabo_secret_version.secret_string)
}

# Configure your Contabo API credentials
provider "contabo" {
  oauth2_client_id     = local.contabo_secret_value_parse["client_id"]
  oauth2_client_secret = local.contabo_secret_value_parse["client_secret"]
  oauth2_user          = local.contabo_secret_value_parse["user_name"]
  oauth2_pass          = local.contabo_secret_value_parse["password"]
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

output "contabo_main_instance_ipv4" {
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
      "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh ./get-docker.sh && sudo usermod -aG docker $USER"
    ]
  }
}

output "bw_contabo_credential_client_id" {
  value     = local.contabo_secret_value_parse["client_id"]
  sensitive = true
}

output "bw_contabo_credential_client_user" {
  value     = local.contabo_secret_value_parse["user_name"]
  sensitive = true
}
