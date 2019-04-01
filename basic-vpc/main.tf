resource "aws_vpc" "main" {
  cidr_block = "172.28.0.0/16"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "g" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
  }
}

module "public-subnets" {
  source                  = "./subnet"
  vpc                     = "${aws_vpc.main.id}"
  cidr_block_prefix       = "172.28.0.0/16"
  cidr_block_newbits      = 8
  map_public_ip_on_launch = true
  az_count                = 3
  name                    = "public"
}

resource "aws_route" "public-internet" {
  route_table_id         = "${module.public-subnets.route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.g.id}"
}

module "private-subnets" {
  source             = "./subnet"
  vpc                = "${aws_vpc.main.id}"
  cidr_block_prefix  = "172.28.0.0/16"
  cidr_block_newbits = 8
  cidr_block_offset  = 4
  az_count           = 3
  name               = "private"
}

module "db-subnets" {
  source             = "./subnet"
  vpc                = "${aws_vpc.main.id}"
  cidr_block_prefix  = "172.28.0.0/16"
  cidr_block_newbits = 8
  cidr_block_offset  = 8
  az_count           = 3
  name               = "db"
}

# block access to db subnets from public
resource "aws_network_acl" "db" {
  vpc_id     = "${aws_vpc.main.id}"
  subnet_ids = ["${module.db-subnets.subnet_ids}"]
}
