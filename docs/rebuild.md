# Host rebuild and verification

## Purpose

Verify that the application can be restored onto a replacement EC2 host using the our Terraform configuration, published images, and an recovery archive outside the host.

## Scope

This activity replaced the EC2 instance along with its root disk while retaining the existing VPC, subnet, security group, ECR repository, SSM deployment document, and CloudWatch resources. This is to demonstrate host reconstruction and application restoration.

## Recovery inputs

Before replacement, a consistent SQLite snapshot was created using Python's SQLite backup API. A private recovery archive was created, transferred to the our device through SSM port forwarding, and verified with SHA-256 before replacing the original host. This archive contained:

- compose.yaml
- release.env
- config-revision.txt
- runtime.env
- vulnlab.sqlite

The snapshot contained:

- 1 user
- 4 notes
- 1 recovery marker (note ID 4, "Card 11 recovery marker")

The archive contains application secret and database records. It remains outside Git with the Terraform state and saved plans.

## Procedure

1. Verified the existing host's application health, image references,
   Compose configuration, and runtime secret permissions before continuing. Also confirmed that a normal Terraform plan reported no changes.
2. Saved private copies of Terraform state and outputs.
3. Prepared a replacement plan  (`-replace=aws_instance.host`).
4. Reviewed the plan (one resource added, one updated, one destroyed).
5. Created, exported, and verified the recovery archive.
6. Applied the replacement plan.
7. Connected to the replacement instance via SSM.
8. Installed Docker from the Amazon Linux repositories and Docker Compose (version 5.5.1) from the official GitHub release, verifying the Compose binary’s SHA-256 checksum.
9. Uploaded the recovery archive.
10. Restored the Compose configuration, image references, and runtime secret.
11. Pulled the application and Redis images in release.env.
12. Used a temporary Compose container to restore SQLite into the new application volume before starting the application.
13. Verified database integrity and the expected record counts.
14. Started both services and checked the container, HTTP, and Redis health.
15. Updated GitHub's AWS_HOST_INSTANCE_ID repo variable.
16. Ran the application deployment workflow on the replacement.
17. Confirmed browser access to the restored notes and proper CloudWatch events.

## Replacement evidence

- Previous instance: i-0c1ef48c9959fa2eb
- Replacement instance: i-0376a213c534f3c22
- Compose configuration revision: 2cc35f2895621181b156ac235072f33a062bc382
- Compose file SHA-256: 03c43f8eeafe8cdc5c0cfa2deea2c951a97afd8d6826d42b92c0d984473c1899

Restoration returned:

- Integrity: ok
- Users: 1
- Notes: 4
- Recovery markers: 1
- Database restored on the new host.

Both application and Redis containers became healthy. The application returned `{"status":"ok"}`, Redis connectivity passed, and the application's logging driver was `awslogs`.

## Deployment after rebuilding

[Successful deployment workflow](https://github.com/setzexe/VulnLab-Cloud/actions/runs/39153873235).

- Application source: 22bc7238cee4a9f9efc15e9dcf9bfcee5ccea6f4
- Workflow commit: 2cc35f2895621181b156ac235072f33a062bc382
- SSM doc version: 2
- SSM command: 0e848803-59ba-443c-9b42-c5077434f461
- Deployed image digest: sha256:f35ac7b971a5d8f50ade11e24ea27e1fe5f8b2f7229918c0ef59f4a2ef13a059

The workflow reported successful container, HTTP, and Redis checks. Web verification proved proper access to the test account's four notes including the recovery marker. CloudWatch received respective `auth.login_failed` events after the rebuild.

## Operation lessons

- Terraform creates the host. However, this configuration does not automatically install Docker or restore application data.
- Replacing the host changes the instance ID. Terraform updates the deployment policy, while the GitHub target variable must also be updated.
- Docker volumes survive regular container replacement, but don't survive deletion of their underlying host disk.
- Restoring an archive restores its capture time state, but not later changes.
- Future commands and instances should get the proper instance ID from Terraform outputs rather than reuse historical IDs from evidence.

## Completion

The demonstration video was deployed. Project access permissions were removed and the AWS infrastructure was torn down.

