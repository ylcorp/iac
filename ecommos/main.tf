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

variable "docker_network_id" {
  description = "docker network id in the host vps"
}

variable "redis_uri" {
  description = "redis uri for project"
}

variable "postgresql_host" {
  description = "postgres db host for project"
}

variable "cms_postgresql_user" {
  description = "postgres db user for cms"
}

variable "cms_postgresql_pwd" {
  description = "postgres db pwd for cms"
}

variable "cms_postgresql_db" {
  description = "postgres db pwd for cms"
}

variable "s3_access_key" {
  description = "access key id for accessing the s3"
}

variable "s3_access_key_secret" {
  description = "access key secret for accessing the s3"
}

variable "s3_bucket" {
  description = "s3 bucket"
}

variable "s3_region" {
  description = "s3 region"
}

variable "secrets" {
  description = "secret stores info secret for ecommos"
}

locals {
  keys = {
    cms_admin_email = "PROD_CMS_ADMIN_EMAIL"
    cms_admin_pwd   = "PROD_CMS_ADMIN_PWD"
    cms_key         = "PROD_CMS_KEY",
    cms_secret      = "PROD_CMS_SECRET"
  }
}
