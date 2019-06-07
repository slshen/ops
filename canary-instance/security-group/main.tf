resource "aws_security_group" "main" {
  name = "${var.name}"
  description = "${var.description}"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group_rule" "rule" {
  count = "${length(var.rules)}"
  security_group_id = "${aws_security_group.main.id}"
  type = "${element(split(",", var.rules[count.index]), 0)}"
  from_port = "${element(split(",", var.rules[count.index]), 1)}"
  to_port = "${element(split(",", var.rules[count.index]), 2)}"
  protocol = "${element(split(",", var.rules[count.index]), 3)}"
  cidr_blocks = [ "${element(split(",", var.rules[count.index]), 4)}" ]
  description = "${element(split(",", var.rules[count.index]), 5)}"
}
