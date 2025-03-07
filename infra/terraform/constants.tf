data "aws_availability_zones" "available" {}

locals {
  region = "eu-west-1"
  name   = "holded"
  vpc_cidr = "10.1.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}
