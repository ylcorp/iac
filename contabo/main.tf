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
