locals {
  yltech_secret_arn  = "arn:aws:secretsmanager:ap-southeast-2:975050295711:secret:yltech-TQ5LJ5"
  contabo_secret_arn = "arn:aws:secretsmanager:ap-southeast-2:975050295711:secret:contabo_api_key-YoxM3t"
}

data "aws_secretsmanager_secret" "yltech_secret" {
  arn = local.yltech_secret_arn
}

data "aws_secretsmanager_secret_version" "yltech_secret_version" {
  secret_id = data.aws_secretsmanager_secret.yltech_secret.id
}

locals {
  yltech_secrets_data = jsondecode(data.aws_secretsmanager_secret_version.yltech_secret_version.secret_string)
  keys = {
    vercel_token     = "VERCEL_API_TOKEN"
    cloudflare_token = "CLOUDFLARE_TOKEN_DNS_DOMAIN"
    aiven_api_token  = "AIVEN_API_TOKEN"
  }
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
