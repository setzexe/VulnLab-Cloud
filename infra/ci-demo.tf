# Temporary CI exercise
resource "aws_security_group" "ci_demo" {
  name        = "vulnlab-ci-demo"
  description = "Temporary configuration used to test security scanning"

  ingress {
    description = "Intentionally unsafe public SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}