terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    netlify = {
      // for static web 
      source  = "royge/netlify"
      version = "0.4.2"
    }
  }
}


locals {
  yltech_secret_arn = "arn:aws:secretsmanager:ap-southeast-2:975050295711:secret:yltech-TQ5LJ5"
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
  }
}

provider "cloudflare" {
  api_token = local.yltech_secrets_data[local.keys.cloudflare_token]
}

provider "vercel" {
  # Or omit this for the api_token to be read
  # from the VERCEL_API_TOKEN environment variable
  api_token = local.yltech_secrets_data[local.keys.vercel_token]
  # # Optional default team for all resources
  # team = "your_team_slug_or_id"
}

provider "netlify" {
  # token = var.netlify_token
  # base_url = var.netlify_base_url
}
