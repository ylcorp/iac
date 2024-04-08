resource "docker_image" "supertoken" {
  name = "registry.supertokens.io/supertokens/supertokens-postgresql:7.0"
}

resource "docker_container" "sannha_supertoken" {
  image    = docker_image.supertoken.image_id
  name     = "sannha_supertokens"
  hostname = "sannha-supertoken.com"
  env = [
    "POSTGRESQL_USER=${local.sannha_secrets_data[local.keys.supertoken.postgresql_user]}",
    "POSTGRESQL_HOST=${docker_container.stufr_postgres.hostname}",
    "POSTGRESQL_PORT=5432",
    "POSTGRESQL_PASSWORD=${local.sannha_secrets_data[local.keys.supertoken.postgresql_pwd]}",
    "POSTGRESQL_DATABASE_NAME=${local.sannha_secrets_data[local.keys.supertoken.postgresql_db]}",
    "API_KEYS=${local.sannha_secrets_data[local.keys.supertoken.api_key]}"
  ]
  # ports {
  #   internal = 3567
  #   external = 3567
  # }
  networks_advanced {
    name = var.docker_network_id
  }
  restart = "unless-stopped"
  healthcheck {
    test     = ["CMD-SHELL", "bash -c 'exec 3<>/dev/tcp/127.0.0.1/3567 && echo -e \"GET /hello HTTP/1.1\\r\\nhost: 127.0.0.1:3567\\r\\nConnection: close\\r\\n\\r\\n\" >&3 && cat <&3 | grep \"Hello\"'"]
    interval = "60s"
    timeout  = "5s"
    retries  = 5
  }
  depends_on = [docker_container.stufr_postgres]
}

resource "docker_image" "sannha_iam" {
  name = "tuancr/sannha-aim:latest"
}

resource "docker_container" "sannha_aim" {
  name  = "sannha_aim"
  image = docker_image.sannha_iam.image_id
  env = [
    "SUPERTOKEN_URI=http://${docker_container.sannha_supertoken.hostname}:3567",
    "MY_DOMAIN=https://aim.sannha.store",
    "SUPERTOKEN_API_KEY=${local.sannha_secrets_data[local.keys.aim.supertoken_api_key]}",
    "GOOGLE_CLIENT_ID_WEB=${local.sannha_secrets_data[local.keys.aim.google_client_id_web]}",
    "GOOGLE_CLIENT_SECRET=${local.sannha_secrets_data[local.keys.aim.google_client_secret]}",
    "GOOGLE_CLIENT_ID_ANDROID=${local.sannha_secrets_data[local.keys.aim.google_client_id_android]}",
    "GOOGLE_CLIENT_ID_IOS=${local.sannha_secrets_data[local.keys.aim.google_client_id_ios]}",
    "FACEBOOK_ID=${local.sannha_secrets_data[local.keys.aim.facebook_id]}",
    "FACEBOOK_SECRET=${local.sannha_secrets_data[local.keys.aim.facebook_secret]}"
  ]
  # ports {
  #   internal = 8080
  #   external = 8080
  # }
  networks_advanced {
    name = var.docker_network_id
  }
  restart    = "always"
  depends_on = [docker_container.sannha_supertoken]
}
