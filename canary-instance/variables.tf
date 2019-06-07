variable "vpc_name" {
  default = "basic"
}

variable "subnet_name" {
  default = "public-us-west-2a"
}

variable "instance_type" {
  default = "t3a.micro"
}

variable "ssh_key" {
  default = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChAxKj3KxDagzFnFPWtHsMmmBlEBgaJjppRcYxZx1ouVmIhYMIlmXg33AS8nZbrVhkLd9memytQzOosFTm2ttBJ3CrtP7tgO+s6bb+VAAOO6exYiUysj/vas+NLRA+VVFk+1+oCeFNxF/o8aiF2eESqSKsKi2Hud5YP7CeOnA9mCfXebIeG1W5garVKZCDHxaM0474b4/C4VuvQOMggDsiL1nZOpdX3RGJxXSOgNEsPLeRTsTTM7qCzyFZMe1ee08MXA6kY6yWKVWBSMkpPDGQ5uqOtASIblHihRVJRP/c13M/Qc0K5MUIGyG9ju50dA0YayPPidu+73F/JxeqYeTr sls@DESKTOP-L2R4GKN
EOF
}
