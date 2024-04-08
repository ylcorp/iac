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
}

module "stufr_contabo" {
  source = "./contabo/stufr"
  providers = {
    docker = docker
    aws    = aws
  }
  contabo_instance_ipv4 = local.contabo_instance_ipv4
  docker_network_id     = module.contabo_config.docker_network_id
}
