resource "aws_default_vpc" "default" {}

output "default_vpc_id" {
  value = aws_default_vpc.default.id
}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "eu-west-3a"
}

output "default_subnet_a_id" {
  value = aws_default_subnet.default_subnet_a.id
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "eu-west-3b"
}

output "default_subnet_b_id" {
  value = aws_default_subnet.default_subnet_b.id
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "eu-west-3c"
}

output "default_subnet_c_id" {
  value = aws_default_subnet.default_subnet_c.id
}
