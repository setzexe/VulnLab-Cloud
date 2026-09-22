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

| Scenario | Observed result | Evidence |
| --- | --- | --- |
| Undeclared variable (local test) | Terraform validation rejects reference | Terminal output recorded during Card 3 |
| Formatting fault in CI | Formatting check failed; validation skipped | [Failed formatting run](https://github.com/setzexe/VulnLab-Cloud/actions/runs/35772834856) |
| Public SSH configuration | Terraform checks passed; Trivy rejected unrestricted ingress with AWS-0107 (HIGH) | [Security rejection](https://github.com/setzexe/VulnLab-Cloud/actions/runs/35773059386) |
| Temporary faults removed | Both jobs passed | [Passing run](https://github.com/setzexe/VulnLab-Cloud/actions/runs/35773774249) |

All tests for verification were removed prior to deployment.

## Merge requirements

The active `protect-main` ruleset requires a pull request and passing `Terraform checks` and `Infrastructure security` checks. The branch must be up to date before merging.
