# Reviewed exception: the temporary host needs outbound HTTPS for
# Systems Manager and software/image downloads without VPC endpoints.
# This permits any IPv4 destination on TCP 443; revisit in Card 5.
#trivy:ignore:AWS-0104
resource "aws_security_group" "host" {
  name        = "vulnlab-host"
  description = "No inbound access. Outbound HTTPS for host services"
  vpc_id      = aws_vpc.lab.id
  tags = {
    Name = "vulnlab-host"
  }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.host.id
  description       = "HTTPS for AWS services + software downloads"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}