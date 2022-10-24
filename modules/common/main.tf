resource "aws_default_vpc" "default" {}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  egress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
}

output "default_security_group_id" {
  value = aws_default_security_group.default.id
}
