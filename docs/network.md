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

## Cost and lifecycle

This configuration contains no EC2 instance, public IPv4 allocation,
NAT gateway, paid interface endpoint, or load balancer.

Review service eligibility and costs before provisioning.
Review and document teardown before the first apply.

## Verification

Pending:

- Terraform formatting + validation.
- Infrastructure security scan with review of findings.
- AWS plan review.
