provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "VulnLab-Cloud"
      ManagedBy = "Terraform"
    }
  }
}