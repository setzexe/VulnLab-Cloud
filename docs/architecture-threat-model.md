# Architecture and threat model

## Status

The design itself is planned and kind of already in the process of creation. (VulnLab itself is already a created application). Controls will require implementation and verification.

## Workload

Deploy an identified, reviewed version of the remediated VulnLab
application. Keep the vulnerable base local only. VulnLab contains application code and tests. This repository contains cloud
infrastructure, deployment configuration, and operational evidence.

## Infrastructure

- One AWS region (us-east-1).
- One VPC with one subnet.
- One Linux EC2 instance running the application container.
- A security group with no arriving rules.
- Application port only on the server's loopback. It should not target anything on the outside web.
- Encrypted EBS storage with SQLite data outside the container.
- Terraform manages the infrastructure. All manual prerequisites are documented.

Proposed outbound connectivity: a public subnet, internet gateway,
and public IPv4 address. Inbound connections remain blocked.

This design should align to the free plan eligibility  and review. We do not want to spend our own funds on this. Public IPv4, compute, storage, and monitoring usage must be included. No NAT gateway, load balancer, or paid interface endpoints are planned.

## Administration and application access

Use Systems Manager Session Manager for administration and application port forwarding. Access requires an authorized AWS identity. The instance initiates outbound connections to Systems Manager. No public SSH or web application endpoint is planned; it would not be necessary.

## Deployment

1. Application tests and security scans validate a selected revision.
2. A container image is built, scanned, and published to a registry.
3. GitHub Actions obtains temporary AWS credentials using OIDC.
4. A (restricted) deployment role starts a deployment
   procedure through Systems Manager.
5. The server pulls the approved image and starts it.
6. Health verification checks whether deployment succeeded.
7. Retain this previous digest for rollback.

Registry + runtime secret storage will be selected before implementation.

## Identity and secrets

- Human development access is separate from the root identity.
- GitHub deployment access is separate from infrastructure administration.
- GitHub's trust only goes as far as the project's directory and respective resources.
- The instance role gets only runtime permissions that are required.
- Secrets are given at runtime, which are excluded from Git and images.
- Terraform state and saved plans are sensitive and should be treated as such.

## Monitoring and recovery

- Send security events from the app to CloudWatch.
- Test an alert using (controlled) failed logins.
- Use CloudTrail to review relevant AWS API activity.
- Do not log passwords, session tokens, or secret values.
- Record deployment version and health results.
- Test rollback to a known working image.
- Test a consistent SQLite backup and restore.
- Keep the recovery backup outside the instance before any destructive tests.

Session Manager port forwarding traffic does not count as session
content, so it is not naturally recorded. Application logs remain necessary.

## Assets

AWS access, integrity of deployment, all application secrets, demo database, Terraform state, logs, and the available cloud credit our account has.

## Trust boundaries

- Developer workstation -> AWS.
- GitHub Actions -> AWS.
- Container registry -> server.
- Application container -> host resources and AWS permissions.

## Initial threats and planned verification

| Threat or failure | Planned control | Verification |
| --- | --- | --- |
| Accidental public exposure | No inbound rules (outside traffic blocked by default), loopback application only | Inspect rules and bindings. Test that direct external access fails |
| Untrusted workflow deploys code | Restricted OIDC trust and deployment permissions | Verify an approved build succeeds and an unapproved build is denied |
| Runtime allows excessive AWS access | Narrow instance permissions, restrict container access to host credentials | Test required and unrelated actions. Verify metadata access restrictions |
| Secret leaks through Git / logs | Ignore local files, sanitized logging | Review tracked files, image configuration, and collected logs |
| Unsafe release reaches deployment | Required tests and scans before deployment | Introduce a failing change and confirm deployment never goes |
| Login abuse is invisible | Structured security events and a threshold alert | Generate failures and inspect the alert + supporting events |
| Release breaks service / integrity | Health checks and previous image digest / backup retained | Deploy an unhealthy version and rollback |
| Database is lost or corrupted | Consistent backup outside the instance | Restore and verify demo records |
| Resources consume credits after use | Usage review, notifications, cleanup inventory, and teardown | Verify resources after cleanup |

## Limitations

- A single server does not provide any high availability.
- Scans reduce risk but do not prove the application is vulnerability free.
- The environment is temporary. Recorded evidence supports the showcase.
  