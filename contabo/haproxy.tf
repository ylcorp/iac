
variable "services" {
  type = list(object({
    name     = string
    hostname = string
    ip       = string
    port     = number
  }))
  default = []
}
locals {
  services = concat(var.services, [
    {
      name     = "node-exporter_contabo"
      hostname = "contabo-exporter.sannha.store"
      port     = 9100
      ip       = module.node_exporter.node_exporter_ip
    }
  ])
}

resource "local_file" "haproxy_config" {
  content  = templatefile("${path.module}/ha-proxy-docker/haproxy.tftpl", { services = local.services })
  filename = "${path.module}/ha-proxy-docker/haproxy.conf"
}

resource "docker_image" "haproxy" {
  name = "yltech-haproxy"
  build {
    context    = "${path.module}/ha-proxy-docker"
    tag        = ["yltech-haproxy:latest"]
    dockerfile = "Dockerfile"
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "ha-proxy-docker/*") : filesha1("${path.module}/${f}")]))
  }
  depends_on = [local_file.haproxy_config]
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

  # env = []
  # for updating in future 
  upload {
    file        = "/usr/local/etc/haproxy/haproxy.cfg"
    source      = "${abspath(path.cwd)}/contabo/ha-proxy-docker/haproxy.conf"
    source_hash = "4cdece7230fafd571584e6257ebb9e52"
  }

  volumes {
    container_path = "/usr/local/etc/haproxy"
    host_path      = "/haproxy"
  }
  restart = "always"
}

