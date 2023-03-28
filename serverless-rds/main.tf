data "aws_vpc" "main" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet_ids" "db" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    BaseName = "${var.db_subnets_base_name}"
  }
}

data "aws_s3_bucket_object" "password" {
  bucket = "${var.ops_bucket}"
  key    = "ops/terraform/us-west-2/serverless-rds/${var.name}-password.txt"
}

resource "aws_db_subnet_group" "default" {
  name_prefix = "${var.name}"
  subnet_ids  = ["${data.aws_subnet_ids.db.ids}"]
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "db" {
  name   = "${var.name}"
  vpc_id = "${data.aws_vpc.main.id}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "db-access" {
  name   = "${var.name}-access"
  vpc_id = "${data.aws_vpc.main.id}"
}

resource "aws_security_group_rule" "db-access" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.db.id}"
  source_security_group_id = "${aws_security_group.db-access.id}"
}

resource "aws_rds_cluster" "serverless" {
  cluster_identifier_prefix = "serverless"
  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  engine_mode               = "serverless"
  master_username           = "db"
  database_name             = "db"
  vpc_security_group_ids    = ["${aws_security_group.db.id}"]
  master_password           = "${trimspace(data.aws_s3_bucket_object.password.body)}"
  tags = {
    Name = "${var.name}"
  }
  deletion_protection = true
}
