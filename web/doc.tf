resource "netlify_deploy_key" "yltech_cli_key" {}

resource "netlify_site" "yltech_cli_doc" {
  name = "yltech_cli_doc"

  repo {
    repo_branch   = "master"
    command       = "yarn doc"
    deploy_key_id = netlify_deploy_key.yltech_cli_key.id
    dir           = "docs"
    provider      = "github"
    repo_path     = "ylteam2024/cli"
  }
}
