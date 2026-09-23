# Cloud network

## Status

Configuration has been defined.

## Design

- Region: us-east-1.
- Dedicated VPC: 10.42.0.0/16.
- Subnet: 10.42.1.0/24, us-east-1a.
- Internet gateway connected to the project VPC.
- Subnet associated with a route table containing an
  IPv4 default route to the internet gateway.

## Connection rules

- Host security group has no inbound rules.
- Ordinary outbound connections are limited to TCP port 443.
- Replies to allowed outbound connections are permitted.

The future build will receive a configured public IPv4 address for outbound internet connectivity. Application and administration access will use authorized Systems Manager sessions.

## Tradeoffs

Outbound HTTPS permits any IPv4 destination. The design uses one subnet and does not provide high availability.

## Reviewed security finding

Trivy reported AWS-0104 (CRITICAL) because the host security group
allows outbound TCP 443 to any IPv4 address.

We ignore this error for this temporary, single host lab. The future host needs outbound HTTPS for Systems Manager and application
delivery. The no inbound rules boundary remains in place. An attacker who gains access to the host could still send data to a different HTTPS destination.

The exception is attached only to the HTTPS egress resource in
`infra/security.tf`. We will reassess the rule when the host's actual connectivity requirements are tested in Card 5.

## Cost and lifecycle

This configuration contains no EC2 instance, public IPv4 allocation,
NAT gateway, paid interface endpoint, or load balancer.

Review service eligibility and costs before provisioning.
Review and document teardown before the first apply.

## Verification

When this lab is finished, run to review removal:

```bash
AWS_PROFILE=vulnlab-dev terraform -chdir=infra plan -destroy 
```

Run to remove the resources:

```bash
AWS_PROFILE=vulnlab-dev terraform -chdir=infra destroy
```

Keep the local Terraform state until cleanup is complete.
