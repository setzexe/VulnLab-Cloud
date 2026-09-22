# Temporary scan exercise. Never apply.
resource "aws_security_group" "ci_demo" {
  name        = "vulnlab-ci-demo"
  description = "Temporary security scan exercise"

  ingress {
    description = "Intentionally unsafe public SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}