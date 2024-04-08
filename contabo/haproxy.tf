resource "docker_image" "haproxy" {
  name = "byjg/easy-haproxy:latest"
}

resource "docker_container" "haproxy" {
  name  = "haproxy-gateway"
  image = docker_image.haproxy.image_id
  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 1936
    external = 1936
  }
  networks_advanced {
    name = docker_network.main_network.id
  }

  env = ["EASYHAPROXY_DISCOVER=docker"]

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }
}

