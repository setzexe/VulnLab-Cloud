resource "aws_security_group" "host" {
  name        = "vulnlab-host"
  description = "No inbound access; outbound HTTPS for host services"
  vpc_id      = aws_vpc.lab.id
  tags = {
    Name = "vulnlab-host"
  }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.host.id
  description       = "HTTPS for AWS services and software downloads"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}