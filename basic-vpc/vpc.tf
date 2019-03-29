resource "aws_vpc" "main" {
  cidr_block = "172.28.0.0/16"
  tags  = {
    Name = "${var.name}"
  }
}

module "public-subnets" {
  source = "./subnet"
  vpc = "${aws_vpc.main.id}"
  cidr_block_prefix = "172.28.0.0/16"
  cidr_block_newbits = 8
  az_count = 2
  name = "public"
}
