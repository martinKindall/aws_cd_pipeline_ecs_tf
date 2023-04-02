
resource "aws_security_group" "spring_app" {
  name        = "spring_app"
  description = "Allows HTTP to web server from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.spring_app.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.spring_app.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
