locals {
  name_dash = "yltech-sns-alarms"
}

resource "aws_sns_topic" "sns_alarms" {
  name = local.name_dash

  tags = {
    Product = "yltech"
  }
}

variable "s3_bucket" {
  type = string
}

variable "webhook" {
  type = string
}

resource "aws_lambda_layer_version" "alarm_lambda_layer" {
  filename   = "${path.module}/lambda/source/alarm/layer.zip"
  layer_name = "alarm_lambda_layer_python"

  compatible_runtimes = ["python3.10"]
}

data "archive_file" "alarm_lambda_source" {
  type        = "zip"
  source_file = "${path.module}/lambda/source/alarm/handler.py"
  output_path = "${path.module}/lambda/source/alarm.zip"
}


# Module
resource "aws_s3_object" "lambda_alarms" {
  bucket = var.s3_bucket
  key    = "lambda-alarms.zip"
  source = data.archive_file.alarm_lambda_source.output_path
}

module "lambda_alarms" {
  source            = "git@github.com:DanielDaCosta/lambda-module.git"
  lambda_name       = "lambda_alarms"
  s3_bucket         = var.s3_bucket
  s3_key            = "lambda-alarms.zip"
  s3_object_version = aws_s3_object.lambda_alarms.version_id
  environment       = "Prod"
  name              = "alarms_nomality"
  description       = "Send Alerts Logic"
  role              = aws_iam_role.iam_for_lambda.arn
  runtime           = "python3.10"
  layers            = [aws_lambda_layer_version.alarm_lambda_layer.arn]
  environment_variables = {
    WEBHOOK_URL = var.webhook
  }

  allowed_triggers = {
    AllowExecutionFromSNS = {
      service    = "sns"
      source_arn = aws_sns_topic.sns_alarms.arn
    }
  }
}

resource "aws_sns_topic_subscription" "lambda_alarm" {
  topic_arn = aws_sns_topic.sns_alarms.arn
  protocol  = "lambda"
  endpoint  = module.lambda_alarms.arn
}

# resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
#   for_each = length(keys(local.alarms_dimensions)) > 0 ? local.alarms_dimensions : {}

#   alarm_name          = "${each.key}-alarm"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "Errors"
#   namespace           = "AWS/Lambda"
#   period              = "60"
#   statistic           = "Sum"
#   threshold           = 0
#   datapoints_to_alarm = 1
#   alarm_actions       = [aws_sns_topic.sns_alarms.arn]
#   alarm_description   = "Triggerd by errors in lambdas"
#   treat_missing_data  = "notBreaching"

#   dimensions = each.value

#   tags = {
#     Product = local.name_dash
#   }
# }

//#TODO: hardcode ec2 instance id, please including the iac module from stufr mainservice, the get the ec2 id from the module output 
resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm_ec2" {
  # Intent            : "This alarm is used to detect high CPU utilization."
  # Threshold Justification : "Typically, you can set the threshold for CPU utilization to 70-80%. However, you can adjust this value based on your acceptable performance level and workload characteristics. For some systems, consistently high CPU utilization may be normal and not indicate a problem, while for others, it may be cause of concern. Analyze historical CPU utilization data to identify the usage, find what CPU utilization is acceptable for your system, and set the threshold accordingly."

  alarm_name                = "AWS/EC2 CPUUtilization InstanceId=i-076cc93d77c6f6ea9"
  alarm_description         = "This alarm helps to monitor the CPU utilization of an EC2 instance. Depending on the application, consistently high utilization levels might be normal. But if performance is degraded, and the application is not constrained by disk I/O, memory, or network resources, then a maxed-out CPU might indicate a resource bottleneck or application performance problems. High CPU utilization might indicate that an upgrade to a more CPU intensive instance is required. If detailed monitoring is enabled, you can change the period to 60 seconds instead of 300 seconds. For more information, see [Enable or turn off detailed monitoring for your instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html)."
  actions_enabled           = false
  ok_actions                = []
  alarm_actions             = [aws_sns_topic.sns_alarms.arn]
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  period                    = 3000
  # just a params correspond to namespace
  dimensions = {
    InstanceId = "i-076cc93d77c6f6ea9"
  }
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

//#TODO: hardcode ec2 instance id, please including the iac module from stufr mainservice, the get the ec2 id from the module output 
resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm_s3_request" {
  # Intent            : "This alarm is used to detect high CPU utilization."
  # Threshold Justification : "Typically, you can set the threshold for CPU utilization to 70-80%. However, you can adjust this value based on your acceptable performance level and workload characteristics. For some systems, consistently high CPU utilization may be normal and not indicate a problem, while for others, it may be cause of concern. Analyze historical CPU utilization data to identify the usage, find what CPU utilization is acceptable for your system, and set the threshold accordingly."

  alarm_name                = "AWS/S3 PostRequests to S3"
  alarm_description         = "This alarm helps to monitor the PostRequests to S3 in each 6 hour"
  actions_enabled           = false
  ok_actions                = []
  alarm_actions             = [aws_sns_topic.sns_alarms.arn]
  insufficient_data_actions = []
  metric_name               = "PostRequests"
  namespace                 = "AWS/S3"
  statistic                 = "Sum"
  period                    = 10800
  # just a params correspond to namespace
  dimensions = {
    BucketName = var.s3_bucket
  }
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 200
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}
