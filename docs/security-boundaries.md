# Security boundary verification

## Purpose

Verify the deployed network configuration and test that the EC2 host can do a required action while an unrelated action is denied.

## Network configuration

Inspected the running instance, every attached security group, Docker port mappings, and application health.

- Instance: i-0c1ef48c9959fa2eb
- Attached security group: sg-0607d8e503019ffc6 only
- Inbound rules: None
- Outbound rules: TCP 443 to 0.0.0.0/0
- Application host is binded to: 127.0.0.1:5000
- Redis host has no published host port binding
- Container health: Application and Redis returned healthy |
- Application health: /health returned `{"status":"ok"}`

The instance has a public IPv4 address, but its security group allows no inbound connections. Application browser access uses SSM port forwarding. Outbound HTTPS alows any IPv4 destination on TCP 443. The application container listens on port 5000.

Redis is reachable on the Compose network; a host port is not needed to be published.

## IAM verification

Tests ran inside an SSM shell on EC2 using the host's role.

`aws sts get-caller-identity` returns:

```text
arn:aws:sts::492767006448:assumed-role/vulnlab-host-ssm/i-0c1ef48c9959fa2eb
```

### Tested allowed action

Called `ecr:BatchGetImage` on the `vulnlab` repository in `us-east-1` for the deployed image `sha256:fa64de4f4c45d263c28f9a2f7c7423bc1fa10cc35aa38376bb8d2d99bf54af08`.

The request returned the matching image digest and tag:

```text
git-22bc7238cee4a9f9efc15e9dcf9bfcee5ccea6f4-run-38086693024-1
```

The failures list was empty. This verifies a permission the host needs when pulling the application image.

### Tested denied action

Ran:

```bash
aws iam list-users --max-items 1 --query 'Users[].UserName' --output json
```

AWS returned `AccessDenied` for the same host role, stating that
no identity based policy allows `iam:ListUsers`. Listing account users is unrelated to running the application. No permissions were added in response to this expected denial.

Both IAM tests were read only.

## Conclusions and limits

The given network configuration matches the intended layout:

- No inbound security-group rules
- Loopback only application (port 5000) publishing
- No published Redis host port

The IAM tests demonstrate one required action succeeding, along with one unrelated action being denied for the EC2 host role.

These results are specific to this configuration. These do not reflect external IAM and cloud configurations and should not be treated as a norm.
