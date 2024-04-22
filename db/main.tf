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
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0"
    }
    aiven = {
      source  = "aiven/aiven"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

locals {
  keys = {
    postgres = {
      admin_name    = "PROD_PG_ADMIN"
      admin_pwd     = "PROD_PG_PWD"
      pgadmin_email = "PROD_PGADMIN_EMAIL"
      pgadmin_pwd   = "PROD_PGADMIN_PWD"
    }
    redis = {}
  }
}

variable "secrets" {
  description = "store contains db secrets"
}

variable "docker_network_id" {
  description = "docker network id to join"
}

variable "pg_hosting_ip" {
  description = "postgres instance hosting ip"
}

variable "cms_pg_username" {
  description = "cms postgres username "
}

variable "cms_pg_pwd" {
  description = "cms postgres pwd"
}

variable "cms_pg_db" {
  description = "cms postgres db"
}

variable "aiven_redis_project" {
  description = "selected project for redis aiven"
}

output "postgres_host" {
  value = docker_container.postgres.hostname
}
