# Cleanup and project completion

This project, focused on applying a remediated web application onto a cloud network with proper security bounds, integrity / recovery, etc., was finished on 26th October, 2026.

## Infrastructure teardown

The recovery archive was verified on my main device before tearing down the project. The private copies of Terraform state, outputs, and the destruction plan were kept outside Git. Nine container images were deleted from the ECR repository. The Terraform destruction plan then correctly showed 0 resources added, 0 resources changed, and 22 resources destroyed. Terraform state had no remaining resource entries afterward.

## Verification

In us-east-1 (North Virginia), there were no EBS volumes, owned EBS snapshots, or Elastic IP allocations remaining. The volume check used the AWS CLI, but Snapshot and Elastic IP checks used the root AWS console since the development had no user permissions to list them.

## Access cleanup

- Removed the temporary VulnLabRecoveryTest policy, along with the remaining VulnLab policies from the development user.
- Deleted the project-specific customer-managed policies.
- Kept the development user's account access policies.
- Disabled the AWS deployment and identity workflow, leaving the Infrastructure CI enabled.
- Removed AWS_HOST_INSTANCE_ID and AWS_DEPLOY_ROLE_ARN from the GitHub variables.

## Material that was kept

The source repositories, demonstration video, documentation, and private recovery backups will remain available. The AWS application itself is offline. Container images were deleted from the ECR; any future deployment will require rebuilding.

The tests verified deployment, failed-login monitoring, image rollback, database restoration, and host replacement recovery. The host recovery test kept the project AWS infrastructure.

## Billing follow up

Resource deletion does not remove any charges from prior usage. The AWS billing should be reviewed to check for unexpected billing.
