terraform {
  required_providers {
    contabo = {
      source = "contabo/contabo"
      version = ">= 0.1.26"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = ">= 0.7.0"
    }
  }
}
