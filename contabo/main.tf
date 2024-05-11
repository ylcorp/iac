terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

resource "docker_network" "main_network" {
  name = "main_network_iac"
}

output "docker_network_id" {
  value = docker_network.main_network.id
}

module "node-exporter" {
  source            = "../monitor/node-exporter"
  docker_network_id = docker_network.main_network.id
  providers = {
    docker = docker
  }
}
