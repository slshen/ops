output "route_table_id" {
  value = "${aws_route_table.r.id}"
}

output "subnet_ids" {
  value = ["${aws_subnet.s.*.id}"]
}
