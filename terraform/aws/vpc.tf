resource "aws_vpc" "main" {
  cidr_block = "${var.subnet_prefix}"
  enable_dns_hostnames = true

  tags {
    Name = "cloudera-${var.env_name}"
  }
}