# Linux host

## Status

Terraform successfully creates the EC2 host in us-east-1. Application deployment is planned for a later card.
Only the remediated VulnLab application will be deployed.

## Design

The host is defined in infra/host.tf and uses the
network described in Cloud network.

- Operating system: Amazon Linux 2023, x86_64
- Instance type: t3.micro
- Root disk: Encrypted 8 GiB gp3, deleted on termination
- Administration: AWS Systems Manager Session Manager
- Inbound security group rules: None

A public IPv4 address allow outbound connectivity through the internet gateway. The security group blocks unwanted inbound connections, including SSH and web traffic. Outbound HTTPS remains a potential attack path if the host is compromised.

The initial AMI is selected through AWS's public Amazon Linux SSM parameter. Terraform ignores later AMI changes to avoid automatically replacing the host when AWS publishes a new image.

## Identity and administration

The vulnlab-host-ssm IAM role trusts EC2 and has the
AmazonSSMManagedInstanceCore policy attached. The vulnlab-host instance profile connects that role to the host. This gives the SSM agent temporary AWS credentials without storing access keys on the machine.

The operator uses this vulnlab-dev identity. Operator policies are currently configured outside Terraform.

To connect, sign in as vulnlab-dev, select us-east-1, and open
Systems Manager -> Session Manager -> Start session. Select the project instance. Session Manager provides shell access through the agent's outbound connection. There is no inbound SSH rule or SSH key configured.

## Verification

The deployment completed with 4 added, 0 changed, 1 destroyed.
The destroyed resource was a tainted IAM role left by an earlier failed creation attempt. Terraform replaced this during recovery.

Run the following from the repository root on the local machine:

```bash
HOST_ID=$(terraform -chdir=infra output -raw host_instance_id)
aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$HOST_ID" \
  --region us-east-1 \
  --profile vulnlab-dev \
  --query 'InstanceInformationList[].{Instance:InstanceId,Status:PingStatus}' \
  --output table
```

Expected status: Online.

Inside the Session Manager terminal:

```bash
whoami
cat /etc/os-release
sudo systemctl is-active amazon-ssm-agent
```

Expected results: ssm-user, Amazon Linux 2023, and active.

Run `exit` to end the session.

## Cost and lifecycle

Compute, EBS storage, and the public IPv4 address are billable resources. Account credits or eligible free usage may cover them. Contiuously check on the account's budget and remaining credits.

For a temporary pause, run on the local machine:

```bash
HOST_ID=$(terraform -chdir=infra output -raw host_instance_id)
aws ec2 stop-instances --instance-ids "$HOST_ID" \
  --region us-east-1 --profile vulnlab-dev
```

Stopping pauses compute usage and releases this automatically assigned public IPv4 address. EBS storage remains allocated and can still incur charges.

To resume:

```bash
aws ec2 start-instances --instance-ids "$HOST_ID" \
  --region us-east-1 --profile vulnlab-dev
```

Read HOST_ID from Terraform again if using a new terminal. The instance may get a different public IPv4 address after starting.

For final teardown (this destroys most essentials including project network, root disk, etc), run:

```bash
AWS_PROFILE=vulnlab-dev terraform -chdir=infra destroy
terraform -chdir=infra state list
```

After a successful cleanup, the state list should contain no managed resources. Confirm the instance is terminated and its root volume is removed in AWS.
