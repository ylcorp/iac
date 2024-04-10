resource "cloudflare_ruleset" "ssl_full_for_vercel_app_stufr" {
  zone_id     = "6477bcdc81e674e4b5dfba915dce5aa3"
  name        = "set ssl to full for some vercel apps"
  description = "To work around the problem of redirect loop between vercel and cloufdlare"
  kind        = "zone"
  phase       = "http_config_settings"
  rules {
    action = "set_config"
    action_parameters {
      ssl = "full"
    }
    expression  = "(http.host eq \"sannha.store\")"
    description = "set ssl of all request from sannha store to full"
    enabled     = true
  }
}


resource "cloudflare_ruleset" "ssl_full_for_vercel_app_khangminh" {
  zone_id     = "889aaa373054674d91d73ca7fe167f06"
  name        = "set ssl to full for some vercel apps"
  description = "To work around the problem of redirect loop between vercel and cloufdlare"
  kind        = "zone"
  phase       = "http_config_settings"
  rules {
    action = "set_config"
    action_parameters {
      ssl = "full"
    }
    expression  = "(http.host eq \"khangminhjsc.vn\")"
    description = "set ssl of all request from khangmingjsc store to full"
    enabled     = true
  }
}

