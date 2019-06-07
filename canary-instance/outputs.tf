output "ip_address" {
  value = "${aws_instance.canary.public_ip}"
}
