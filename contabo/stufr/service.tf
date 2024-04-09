locals {
  main_service_infra_tag        = "latest"
  main_service_infra_image_name = "tuancr/sannha-main-service-infra"
  # landing_page_tag              = "latest"
  # landing_page_image_name       = "tuancr/sannha-landing-page"
}

resource "docker_image" "sannha-main-service-infra" {
  name = "${local.main_service_infra_image_name}:${local.main_service_infra_tag}"
}

locals {
  main_service_infra_envs_map_secret_keys = [
    ["SUPERTOKEN_APPNAME", "PROD_MAIN_SERVICE_INFRA_SUPERTOKEN_APP_NAME"],
    ["AIM_BASE_URI", "PROD_MAIN_SERVICE_INFRA_IAM_BASE_URI"],
    ["AIM_WEBSITE_URI", "PROD_MAIN_SERVICE_INFRA_IAM_WEBSITE_URI"],
    ["AIM_API_BASE_PATH", "PROD_MAIN_SERVICE_INFRA_IAM_API_BASE_PATH"],
    ["WEBSITE_AIM_BASE_PATH", "PROD_MAIN_SERVICE_INFRA_WEBSITE_IAM_BASE_PATH"],
    ["WEBSITE_AIM_BASE_PATH", "PROD_MAIN_SERVICE_INFRA_WEBSITE_IAM_BASE_PATH"],
    ["SUPERTOKEN_API_KEY", "PROD_MAIN_SERVICE_INFRA_SUPERTOKEN_API_KEY"]
  ]
  main_service_infra_labels = [
    ["port", "80"],
    ["localport", "8080"],
    ["host", "main-service-api.sannha.store"]
  ]
}

resource "docker_container" "sannha-main-service-infra" {
  image = docker_image.sannha-main-service-infra.image_id
  name  = "sannha-main-service-infra"
  env = concat([
    "SUPERTOKEN_URI=http://${docker_container.stufr_supertoken.hostname}:${local.stufr.main_port}",
  ], [for map_key in local.main_service_infra_envs_map_secret_keys : "${map_key[0]}=${local.sannha_secrets_data[map_key[1]]}"])
  restart = "unless-stopped"
  dynamic "labels" {
    for_each = local.main_service_infra_labels
    content {
      label = "easyhaproxy.http.${labels.value[0]}"
      value = labels.value[1]
    }
  }
  networks_advanced {
    name = var.docker_network_id
  }
}

# resource "docker_image" "stufr-landing-page" {
#   name = "${local.landing_page_image_name}:${local.landing_page_tag}"
# }

# resource "docker_container" "stufr-landing-page" {
#   image   = docker_image.stufr-landing-page.image_id
#   name    = "stufr_landing_page"
#   restart = "unless-stopped"
#   networks_advanced {
#     name = var.docker_network_id
#   }
# } --> move to vercel
