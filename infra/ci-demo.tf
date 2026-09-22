output "ci_demo" {
  value = var.demo_value_not_declared
}terraform -chdir=infra fmt