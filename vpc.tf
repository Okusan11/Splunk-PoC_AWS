# --------------------------------------
# VPC
# --------------------------------------

resource "aws_vpc" "miratsuku_vpc_1" {
  cidr_block                       = "10.2.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "miratsuku-vpc-1"
  }
}