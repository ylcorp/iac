provider "aiven" {
  api_token = local.yltech_secrets_data[local.keys.aiven_api_token]
}

data "aiven_organization" "main" {
  name = "My Organization"
}

resource "aiven_project" "yltech" {
  project   = "yltech"
  parent_id = data.aiven_organization.main.id
}
