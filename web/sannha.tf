resource "vercel_project" "sannha-landing-page" {
  name      = "sannha-landing-page"
  framework = "nextjs"
  git_repository = {
    type = "github"
    repo = "san-nha/landing-page"
  }
}

resource "vercel_deployment" "sannha_landing_page" {
  project_id = vercel_project.sannha-landing-page.id
  ref        = "master" # or a git branch
}

resource "vercel_project_domain" "sannha_landing_page" {
  project_id = vercel_project.sannha-landing-page.id
  domain     = "sannha.store"
}
