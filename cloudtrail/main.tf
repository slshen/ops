data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  bucket_name = "slshen-logs-us-west-2"
  cloudtrail_sns_arn = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cloudtrail"
}

data "aws_iam_policy_document" "logs" {
  statement {
    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]
    }
    actions = [ "s3:GetBucketAcl" ]
    resources = [ "arn:aws:s3:::${local.bucket_name}" ]
  }
  statement {
    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]
    }
    actions = [ "s3:PutObject" ]
    resources = [ "arn:aws:s3:::${local.bucket_name}/*" ]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [ "bucket-owner-full-control" ]
    }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.bucket_name}"
  policy = "${data.aws_iam_policy_document.logs.json}"
  acl = "private"
  lifecycle_rule {
    id      = "log"
    enabled = true
    expiration {
      days = 45
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = "${local.bucket_name}"
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "sns-cloudtrail" {
  statement {
    principals {
      type = "AWS"
      identifiers = [ "*" ]
    }
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]
    resources = [ "${local.cloudtrail_sns_arn}" ]
    condition {
      test = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [ "${data.aws_caller_identity.current.account_id}" ]
    }
  }

}

resource "aws_sns_topic" "cloudtrail" {
  name = "cloudtrail"
  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "${local.cloudtrail_sns_arn}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${data.aws_caller_identity.current.account_id}"
        }
      }
    },
    {
      "Sid": "AllowCloudtrail",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "${local.cloudtrail_sns_arn}"
    }
  ]
}
EOF
}

resource "aws_cloudtrail" "default" {
  name = "default"
  s3_bucket_name = "${local.bucket_name}"
  s3_key_prefix = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail = true
  sns_topic_name = "cloudtrail"
  depends_on = [ "aws_sns_topic.cloudtrail" ]
}
