resource "aws_iam_role" "lambda" {
  name = "${var.name}"
  description = "Allow a lambda function to terminate an instance"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "terminate" {
  statement {
    actions = [ "ec2:DescribeInstances" ]
    resources = [ "*" ]
  }
  statement {
    actions = [ "ec2:TerminateInstances" ]
    resources = [ "*" ]
    condition {
      test = "StringEquals"
      variable = "ec2:ResourceTag/${var.tag_name}"
      values = [ "${var.tag_value}" ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda-basic" {
  role = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda-terminate" {
  role = "${aws_iam_role.lambda.name}"
  name = "terminate-instances"
  policy = "${data.aws_iam_policy_document.terminate.json}"
}

resource "aws_lambda_function" "terminate" {
  filename = "${path.module}/function.zip"
  function_name = "${var.name}"
  handler = "function.handler"
  role = "${aws_iam_role.lambda.arn}"
  runtime = "python3.7"
  source_code_hash = "${base64sha256(file("${path.module}/function.zip"))}"
}
  
resource "aws_cloudwatch_event_rule" "hourly" {
  name = "hourly"
  description = "Run once/hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "terminate" {
  rule = "${aws_cloudwatch_event_rule.hourly.name}"
  arn = "${aws_lambda_function.terminate.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.terminate.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.hourly.arn}"
}
