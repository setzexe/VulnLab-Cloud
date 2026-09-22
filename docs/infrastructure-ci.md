# Infrastructure CI

## Purpose

The CI (Continuous Integration) checks Terraform changes before they are merged. The workflow runs without AWS credentials and does not use resources.

## Workflow

Access the workflow at `.github/workflows/infrastructure.yml`

- Pull requests targeting `main`.
- Pushes to `main`.

## Checks

- Terraform formatting: Enforce consistent HCL formatting
- Terraform initialization: Install providers using the lock file
- Terraform validation: Detect invalid arguments, types, and references
- Trivy configuration scan: Reject HIGH and CRITICAL findings in infrastructure

## Versions

- Terraform: 1.16.3.
- Trivy: 0.69.3.
- AWS provider: exact version recorded in `infra/.terraform.lock.hcl`.
- GitHub Actions references are pinned to commit hashes.

## Verification table

| Scenario | Expected result | Observed result |
| --- | --- | --- |
| Undeclared variable reference | Terraform validation fails | Terraform validation fails |
| SSH allowed from any IPv4 address | Security scan fails | Security scan fails |
| Demonstration faults removed | Both jobs pass | Both jobs pass |

All tests for verification were removed prior to deployment.

## Limitations

Validation does not prove that AWS permissions or deployment will work.
Security scanning identifies known configuration problems, not every risk.
The security failure threshold is HIGH and CRITICAL.

Failed checks only block merging when repository rules require them.
No deployment workflow exists yet.
