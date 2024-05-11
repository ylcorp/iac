terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

variable "region" {
  type        = string
  description = "Aws region"
}

