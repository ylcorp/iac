terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

resource "docker_image" "node_exporter" {
  name = "prom/node-exporter:latest"
}

variable "docker_network_id" {
  type = string
}

resource "docker_container" "node_exporter" {
  image    = docker_image.node_exporter.image_id
  name     = "node_exporter"
  hostname = "node_exporter"
  volumes {
    container_path = "/host/proc"
    host_path      = "/proc"
    read_only      = true
  }
  volumes {
    container_path = "/host/sys"
    host_path      = "/sys"
    read_only      = true
  }
  volumes {
    container_path = "/rootfs"
    host_path      = "/"
    read_only      = true
  }
  networks_advanced {
    name = var.docker_network_id
  }
  command = [
    "--path.procfs=/host/proc"
    , "--path.rootfs=/rootfs"
    , "--path.sysfs=/host/sys"
    , "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
  ]
  restart = "unless-stopped"
}

output "node_exporter_ip" {
  value = docker_container.node_exporter.network_data[0].ip_address
}
