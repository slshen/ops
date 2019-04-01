variable "cidr_block_prefix" {}

variable "cidr_block_newbits" {}

variable "cidr_block_offset" {
  default = 0
}

variable "name" {}

variable "vpc" {}

variable "az_count" {
  default = 99
}

variable "map_public_ip_on_launch" {
  default = false
}
