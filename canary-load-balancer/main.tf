data "aws_vpc" "main" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    BaseName = "public"
  }
}

data "aws_security_group" "app" {
  vpc_id = "${data.aws_vpc.main.id}"
  name = "canary"
}

module "lb-security-group" {
  source = "./../canary-instance/security-group"
  name = "canary-lb"
  vpc_id = "${data.aws_vpc.main.id}"
  description = "Canary load balancer security group"
  rules = [
    "ingress,80,80,tcp,0.0.0.0/0,http",
    "ingress,443,443,tcp,0.0.0.0/0,https",
  ]
}

resource "aws_security_group_rule" "lb-app" {
  type = "egress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = "${data.aws_security_group.app.id}"
  security_group_id = "${module.lb-security-group.security_group_id}"
  description = "allow outbound to app"
}

resource "aws_security_group_rule" "app-lb" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  security_group_id = "${data.aws_security_group.app.id}"
  source_security_group_id = "${module.lb-security-group.security_group_id}"
  description = "allow inbound lb"
}
  
resource "aws_lb" "canary" {
  name_prefix = "canary"
  internal = false
  load_balancer_type = "application"
  security_groups = [ "${module.lb-security-group.security_group_id}" ]
  subnets = [ "${data.aws_subnet_ids.public.ids}" ]
  tags {
    Name = "canary"
  }
}

/*
resource "aws_lb_listener" "front" {
 load_balancer_arn = "${aws_lb.front_end.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.front_end.arn}"
  }
}*/
