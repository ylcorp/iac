resource "vercel_project" "khangminh-portal" {
  name      = "khangminh-portal"
  framework = "nextjs"
  git_repository = {
    type = "github"
    repo = "ylcorp/khangminh-web"
  }
}

resource "vercel_deployment" "khangminh-portal" {
  project_id = vercel_project.khangminh-portal.id
  ref        = "master" # or a git branch
}

resource "vercel_project_domain" "khangminh-portal" {
  project_id = vercel_project.khangminh-portal.id
  domain     = "khangminhjsc.vn"
}
