resource "aws_iam_role" "role" {
  name = "${var.name}"
  description = "${var.description}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags {
    Name = "${var.name}"
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.name}"
  role = "${aws_iam_role.role.name}"
}

