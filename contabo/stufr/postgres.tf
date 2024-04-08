locals {
  postgres_data_path = "/root/app/postgres/postgres/data"
}

resource "null_resource" "prepare_for_postgres_deploying" {
  connection {
    type        = "ssh"
    host        = var.contabo_instance_ipv4
    user        = "root"                    # or your desired SSH user
    private_key = file("~/.ssh/id_ed25519") # Path to your private key
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.postgres_data_path}"
    ]
  }
}


resource "docker_image" "stufr_postgres" {
  name = "postgres:latest"
}


resource "docker_container" "stufr_postgres" {
  image    = docker_image.stufr_postgres.image_id
  hostname = "stufr_postgres"
  name     = "stufr_postgres"
  env = [
    "POSTGRES_USER=${local.sannha_secrets_data[local.keys.postgres.admin_name]}",
    "POSTGRES_PASSWORD=${local.sannha_secrets_data[local.keys.postgres.admin_pwd]}",
    "PGADMIN_DEFAULT_EMAIL=${local.sannha_secrets_data[local.keys.postgres.pgadmin_email]}",
    "PGADMIN_DEFAULT_PASSWORD=${local.sannha_secrets_data[local.keys.postgres.pgadmin_pwd]}",
    "PGDATA=/data/postgres"
  ]
  volumes {
    container_path = "/data/postgres"
    host_path      = local.postgres_data_path
  }
  ports {
    internal = 5432
    external = 5433
  }
  networks_advanced {
    name = var.docker_network_id
  }
  restart = "unless-stopped"
  healthcheck {
    test = [
      "CMD",
      "pg_isready",
      "-U",
      "${local.sannha_secrets_data[local.keys.postgres.admin_name]}",
      "-d",
      "postgres"
    ]
  }
}
