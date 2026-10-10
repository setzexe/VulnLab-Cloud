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

output "host_instance_id" {
  description = "EC2 instance ID for Systems Manager sessions"
  value       = aws_instance.host.id
}

output "app_repository_url" {
  description = "Private ECR repository for application"
  value       = aws_ecr_repository.app.repository_url
}

output "github_deploy_role_arn" {
  description = "IAM role assumed by the GitHub deployment workflow"
  value       = aws_iam_role.github_deploy.arn
}

output "deployment_document_name" {
  description = "SSM document used for application deployment"
  value       = aws_ssm_document.deploy.name
}

output "deployment_document_version" {
  description = "Current deployment document version"
  value       = aws_ssm_document.deploy.latest_version
}

output "application_log_group_name" {
  description = "CloudWatch log group for application output"
  value       = aws_cloudwatch_log_group.application.name
}

output "failed_login_alarm_name" {
  description = "CloudWatch alarm for repeated failed logins"
  value       = aws_cloudwatch_metric_alarm.failed_logins.alarm_name
}