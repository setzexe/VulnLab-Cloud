# Automated deployment

## Status

GitHub Actions can obtain temporary AWS credentials through OIDC.
Verification succeeded from main, while being rejected from a test branch.

Application deployment automation is the remaining part of Card 8.

## Design

Terraform defines the GitHub identity provider and the
`vulnlab-github-deploy` role. The trust policy requires the AWS STS audience and the exact OIDC subject for the VulnLab-Cloud repository's main branch.

The verification workflow requests a 15-minute session (900 seconds). Permanent AWS access keys are not stored in GitHub.

The trust condition applies to eligible jobs on main. Changes to workflows on main will require review.

## Verification

- Main branch: role check succeeded and returned the wanted AWS identity.
- Test branch: AWS rejected AssumeRoleWithWebIdentity.
- Infrastructure CI: formatting, validation, and security checks passed.

## Cost and lifecycle

Identity verification does not require starting EC2. The existing EC2 storage and ECR images remain allocated. GitHub Actions
usage follows the repository's applicable usage limits.

Terraform manages the deployment role and, when created by this project, the GitHub identity provider.
