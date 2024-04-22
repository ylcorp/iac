locals {
  postgres_data_path = "/root/app/postgres/postgres/data"
}

resource "docker_image" "postgres" {
  name = "postgres:latest"
}


resource "docker_container" "postgres" {
  image    = docker_image.postgres.image_id
  hostname = "main_yl_postgres"
  name     = "main_yl_postgres"
  env = [
    "POSTGRES_USER=${var.secrets[local.keys.postgres.admin_name]}",
    "POSTGRES_PASSWORD=${var.secrets[local.keys.postgres.admin_pwd]}",
    "PGADMIN_DEFAULT_EMAIL=${var.secrets[local.keys.postgres.pgadmin_email]}",
    "PGADMIN_DEFAULT_PASSWORD=${var.secrets[local.keys.postgres.pgadmin_pwd]}",
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
      "${var.secrets[local.keys.postgres.admin_name]}",
      "-d",
      "postgres"
    ]
  }
}

provider "postgresql" {
  alias    = "main_pg_db"
  host     = var.pg_hosting_ip
  sslmode  = "disable"
  port     = docker_container.postgres.ports[0].external
  username = var.secrets[local.keys.postgres.admin_name]
  password = var.secrets[local.keys.postgres.admin_pwd]
}

resource "postgresql_role" "cms_pg_role" {
  provider   = postgresql.main_pg_db
  name       = var.cms_pg_username
  login      = true
  password   = var.cms_pg_pwd
  depends_on = [docker_container.postgres]
}

resource "postgresql_database" "cms_db" {
  name              = var.cms_pg_db
  provider          = postgresql.main_pg_db
  owner             = postgresql_role.cms_pg_role.name
  template          = "template0"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

output "cms_pg_db" {
  value = postgresql_database.cms_db.name
}

output "cms_pg_username" {
  value = postgresql_role.cms_pg_role.name
}

output "cms_pg_pwd" {
  value = postgresql_role.cms_pg_role.password
}
