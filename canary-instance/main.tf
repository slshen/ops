data "aws_vpc" "main" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet_ids" "subnet" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "${var.subnet_name}"
  }
}

data "aws_ami" "amazon-linux" {
  owners = [ "amazon" ]
  most_recent = true
  filter {
    name = "name"
    values = [ "amzn-ami-hvm-*-x86_64-ebs" ]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "aws" {
  key_name = "aws"
  public_key = "${var.ssh_key}"
}

module "canary-security-group" {
  source = "security-group"
  name = "canary"
  description = "canary"
  vpc_id = "${data.aws_vpc.main.id}"
  rules = [
    "ingress,22,22,tcp,${var.my_ip}/32,ssh",
    "ingress,8,8,icmp,0.0.0.0/0,ping",
    "egress,53,53,udp,0.0.0.0/0,dns",
    "egress,123,123,udp,0.0.0.0/0,ntp",
    "egress,0,65535,tcp,0.0.0.0/0,default outbound"
  ]   
}

module "canary-role" {
  source = "ec2-instance-profile"
  name = "canary"
}

resource "aws_iam_role_policy_attachment" "canary-read-only" {
  role = "${module.canary-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "canary-ssm" {
  role = "${module.canary-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_instance" "canary" {
  ami = "${data.aws_ami.amazon-linux.id}"
  instance_type = "${var.instance_type}"  
  vpc_security_group_ids = [ "${module.canary-security-group.security_group_id}" ]
  subnet_id = "${data.aws_subnet_ids.subnet.ids[0]}"
  key_name = "aws"
  ebs_optimized = true
  iam_instance_profile = "${module.canary-role.name}"
  tags {
    Name = "canary"
  }
}

module "terminator" {
  source = "lambda-terminator"
  name = "canary-instance-terminator"
  tag_name = "Name"
  tag_value = "canary"
}
