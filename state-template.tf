terraform {
  backend "s3" {
    bucket = "slshen-us-west-2"
    key    = "ops/terraform/us-west-2/@name@/terraform.tfstate"
    region = "us-west-2"
  }
}
