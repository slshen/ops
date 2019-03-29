data "aws_availability_zones" "available" {}

locals {
  az_names = "${slice(data.aws_availability_zones.available.names, 0, min(var.az_count, length(data.aws_availability_zones.available.names)))}"
}

resource "aws_subnet" "s" {
  vpc_id = "${var.vpc}"
  availability_zone = "${local.az_names[count.index]}"
  count = "${length(local.az_names)}"
  cidr_block = "${cidrsubnet(var.cidr_block_prefix, var.cidr_block_newbits, var.cidr_block_offset + count.index)}"
  tags = {
    Name = "${var.name}-${local.az_names[count.index]}"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${var.vpc}"
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "a" {
  count = "${length(local.az_names)}"
  subnet_id = "${aws_subnet.s.*.id[count.index]}"
  route_table_id = "${aws_route_table.r.id}"
}
