locals {
  directus_dir = "/root/app/directus/"
}

resource "docker_image" "directus" {
  name = "directus/directus:10.10.5"
}

locals {
  haproxy_labels_directus = [
    ["port", "80"],
    ["localport", "8055"],
    ["host", "directus-cms.sannha.store"]
  ]
}

resource "docker_container" "directus" {
  image    = docker_image.directus.image_id
  name     = "ecommos_directus"
  hostname = "ecommos_directus"
  env = [
    "KEY=${var.secrets[local.keys.cms_key]}",
    "SECRET=${var.secrets[local.keys.cms_secret]}",
    "CACHE_ENABLED=true",
    "CACHE_STORE=redis",
    "REDIS=${var.redis_uri}",
    "DB_CLIENT=pg",
    "DB_HOST=${var.postgresql_host}",
    "DB_PORT=5432",
    "DB_DATABASE=${var.cms_postgresql_db}",
    "DB_USER=${var.cms_postgresql_user}",
    "DB_PASSWORD=${var.cms_postgresql_pwd}",
    "ADMIN_EMAIL=${var.secrets[local.keys.cms_admin_email]}",
    "ADMIN_PASSWORD=${var.secrets[local.keys.cms_admin_pwd]}",
    "STORAGE_LOCATIONS=amazon",
    "STORAGE_AMAZON_DRIVER=s3",
    "STORAGE_AMAZON_ROOT=cms",
    "STORAGE_AMAZON_KEY=${var.s3_access_key}",
    "STORAGE_AMAZON_SECRET=${var.s3_access_key_secret}",
    "STORAGE_AMAZON_BUCKET=${var.s3_bucket}",
    "STORAGE_AMAZON_REGION=${var.s3_region}"
  ]
  volumes {
    container_path = "/directus/extensions"
    host_path      = "${local.directus_dir}/extensions"
  }
  dynamic "labels" {
    for_each = local.haproxy_labels_directus
    content {
      label = "easyhaproxy.http.${labels.value[0]}"
      value = labels.value[1]
    }
  }
  networks_advanced {
    name = var.docker_network_id
  }
  restart = "unless-stopped"
}
