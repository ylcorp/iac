provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "Aws region to apply the changes"
  default     = "ap-southeast-2"
}

