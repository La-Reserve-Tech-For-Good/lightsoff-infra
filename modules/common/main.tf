resource "aws_default_vpc" "default" {}

output "default_vpc_id" {
  value = aws_default_vpc.default.id
}
