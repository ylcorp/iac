provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "Aws region to apply the changes"
  default     = "ap-southeast-2"
}


// prepare s3 user for directus

data "aws_s3_bucket" "main_s3_storage" {
  bucket = local.yltech_secrets_data["MAIN_S3_BUCKET_NAME"]
}

data "aws_iam_policy" "s3_main_bucket_policy" {
  name = "s3_image_server_policy"
}

resource "aws_iam_user" "cms_user" {
  name = "yltech-cms-user"
}

# Attach the S3 access role to the IAM user
resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.cms_user.name
  policy_arn = data.aws_iam_policy.s3_main_bucket_policy.arn
}


# Generate an access key and secret access key for the IAM user
resource "aws_iam_access_key" "cms_user_access_key" {
  user = aws_iam_user.cms_user.name
}
