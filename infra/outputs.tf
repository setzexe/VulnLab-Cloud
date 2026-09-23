output "vpc_id" {
  description = "VPC identifier"
  value       = aws_vpc.lab.id
}

output "subnet_id" {
  description = "Subnet for VulnLab host"
  value       = aws_subnet.lab.id
}

output "host_security_group_id" {
  description = "Security group for VulnLab host"
  value       = aws_security_group.host.id
}