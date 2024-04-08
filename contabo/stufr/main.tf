terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

locals {
  sannha_secrets_arn = "arn:aws:secretsmanager:ap-southeast-2:975050295711:secret:sannha_secrets-Ybow83"
}

data "aws_secretsmanager_secret" "sannha_secret_meta" {
  arn = local.sannha_secrets_arn
}

data "aws_secretsmanager_secret_version" "sannha_secret_version" {
  secret_id = data.aws_secretsmanager_secret.sannha_secret_meta.id
}

locals {
  sannha_secrets_data = jsondecode(data.aws_secretsmanager_secret_version.sannha_secret_version.secret_string)
}

locals {
  keys = {
    supertoken = {
      postgresql_user = "PROD_SUPERTOKEN_PG_USER"
      postgresql_pwd  = "PROD_SUPERTOKEN_PG_PWD"
      postgresql_db   = "PROD_SUPERTOKEN_PG_DB"
      api_key         = "PROD_SUPERTOKEN_API_KEY"
    }
    aim = {
      supertoken_api_key       = "PROD_AIM_SUPERTOKEN_API_KEY"
      google_client_id_web     = "PROD_AIM_GOOGLE_CLIENT_ID_WEB"
      google_client_secret     = "PROD_AIM_GOOGLE_CLIENT_SECRET"
      google_client_id_android = "PROD_AIM_GOOGLE_CLIENT_ID_ANDROID"
      google_client_id_ios     = "PROD_AIM_GOOGLE_CLIENT_ID_IOS"
      facebook_id              = "PROD_AIM_FACEBOOK_ID"
      facebook_secret          = "PROD_AIM_FACEBOOK_SECRET"
    }
    postgres = {
      admin_name    = "PROD_PG_ADMIN"
      admin_pwd     = "PROD_PG_PWD"
      pgadmin_email = "PROD_PGADMIN_EMAIL"
      pgadmin_pwd   = "PROD_PGADMIN_PWD"
    }
  }
}

variable "contabo_instance_ipv4" {
  description = "main contabo instance ipv4"
  default     = "0.0.0.0"
}

variable "docker_network_id" {
  description = "contabo main network id"
  default     = "unknown"
}

output "passing_param" {
  value = "${var.contabo_instance_ipv4} ${var.docker_network_id}"
}
