# AWS development access

## Purpose

Establish a separate development identity for VulnLab-Cloud through IAM. We need to also verify that the AWS CLI uses the correct account identity and region, with narrowly scoped permissions.

We should **never** casually use root account.

## Configuration

- Development user:  `vulnlab-dev`
- AWS CLI profile: `vulnlab-dev`
- Region: `us-east-1`

## Authentication

The sign in method uses browser authentication to get temporary CLI credentials.

```bash
aws login --profile vulnlab-dev
```

All credentials and login caches remain outside the repository. This command should be repeated when a session expires.

## Initial permissions

- `SignInLocalDevelopmentAccess`: blocks CLI authentication from a browser.
- `VulnLabInitialInspection`: blocks `ec2:DescribeVpcs` in `us-east-1` (Only traffic from that region may access).

Vulnlab-dev has no billing or creation permissions. This explains why the console cost and usage widgets display `Access denied`.

## Verification results

### Identity

```bash
aws sts get-caller-identity --profile vulnlab-dev
```

Result:

```text
arn:aws:iam::<ACCOUNT_ID>:user/vulnlab-dev
```

### Region

```bash
aws configure get region --profile vulnlab-dev
```

Result:

```text
us-east-1
```

### Permitted operation

```bash
aws ec2 describe-vpcs --region us-east-1 --profile vulnlab-dev
```

Result: successful response containing an available default VPC with
CIDR `172.31.0.0/16`.

### Denied operation

```bash
aws iam list-users --profile vulnlab-dev
```

Result: `AccessDenied`. No identity based policy allowed
`iam:ListUsers`. This is the wanted result for the configured permissions.
