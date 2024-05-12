terraform {
  required_providers {
    contabo = {
      source  = "contabo/contabo"
      version = ">= 0.1.26"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
    aiven = {
      source  = "aiven/aiven"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "docker" {
  host     = "ssh://root@${local.contabo_instance_ipv4}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

module "contabo_config" {
  source = "./contabo"
  providers = {
    docker = docker
  }
  services = [

    {
      name     = "main-service-api_stufr"
      hostname = "main-service-api.sannha.store"
      port     = 8080
      ip       = module.stufr_contabo.service_ip.main_service
    },
    {
      name     = "iam_stufr"
      hostname = "iam.sannha.store"
      port     = 8080
      ip       = module.stufr_contabo.service_ip.iam
    },
    {
      name     = "supertoken_stufr"
      hostname = "supertoken.sannha.store"
      port     = 3567
      ip       = module.stufr_contabo.service_ip.supertoken
    },
    {
      name     = "directus_yltech"
      hostname = "directus-cms.sannha.store"
      port     = 8055
      ip       = module.ecommos.directus_ip
    }
  ]
}

module "db" {
  source              = "./db"
  secrets             = local.yltech_secrets_data
  docker_network_id   = module.contabo_config.docker_network_id
  cms_pg_username     = local.yltech_secrets_data["PROD_CMS_PG_USER"]
  cms_pg_pwd          = local.yltech_secrets_data["PROD_CMS_PG_PWD"]
  cms_pg_db           = local.yltech_secrets_data["PROD_CMS_PG_DB"]
  pg_hosting_ip       = local.contabo_instance_ipv4
  aiven_redis_project = aiven_project.yltech.id
  providers = {
    docker = docker
    aws    = aws
    aiven  = aiven
  }
}

module "stufr_contabo" {
  source = "./contabo/stufr"
  providers = {
    docker = docker
    aws    = aws
  }
  postgres_host         = module.db.postgres_host
  contabo_instance_ipv4 = local.contabo_instance_ipv4
  docker_network_id     = module.contabo_config.docker_network_id
}

module "vercel" {
  source = "./vercel"
  providers = {
    aws = aws
  }
}

module "ecommos" {
  source = "./ecommos"
  providers = {
    docker = docker
    aws    = aws
  }
  docker_network_id    = module.contabo_config.docker_network_id
  redis_uri            = module.db.redis_uri
  postgresql_host      = module.db.postgres_host
  cms_postgresql_user  = module.db.cms_pg_username
  cms_postgresql_pwd   = module.db.cms_pg_pwd
  cms_postgresql_db    = module.db.cms_pg_db
  secrets              = local.yltech_secrets_data
  s3_bucket            = data.aws_s3_bucket.main_s3_storage.id
  s3_region            = data.aws_s3_bucket.main_s3_storage.region
  s3_access_key_secret = aws_iam_access_key.cms_user_access_key.secret
  s3_access_key        = aws_iam_access_key.cms_user_access_key.id
}

module "aws" {
  source = "./aws"
  providers = {
    aws = aws
  }
  webhook   = local.yltech_secrets_data["MONITOR_DISCORD_WEB_HOOK"]
  s3_bucket = data.aws_s3_bucket.main_s3_storage.id
  region    = var.aws_region
}
