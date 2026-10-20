# Security monitoring

## Purpose

The security monitoring system exists to collect application security events, detect repeated failed logins, and review AWS activity related to an automated deployment.

## Application logs

The application gives structured JSON events for failed logins. These events have a timestamp, event name, and outcome. Usernames, passwords, or session tokens are not displayed. Docker forwards application output to the CloudWatch Logs group `/vulnlab/application`.

The EC2 host role can create log streams and write events within the application log group.

## Failed login detection

The login filter matches:

`{ $.event = "auth.login_failed" && $.outcome = "failure" }`

Each matching event brings one count to:

- Namespace: `VulnLab/Security`
- Metric: `FailedLogins`

The `vulnlab-failed-logins` alarm checks the sum over a five minute period and enters ALARM when the count reaches three. This is a simple static application alarm. It does not identify an attacker or automatically block requests.

Missing data is treated as not breaching.

## Verification (2026-10-10)

Three self-made failed login attempts created three JSON events in CloudWatch at around `2026-10-10T21:20:50Z`.

The inspected events contained only:

- `timestamp`
- `event`
- `outcome`

## AWS activity review

CloudTrail recorded the [deployment request](https://github.com/setzexe/VulnLab-Cloud/actions/runs/38086693024) that we used for this checkpoint:

- Event ID: 0f1c1026-8070-4ecf-95f5-f8c116c38d04
- Time: 2026-10-10T21:13:08Z
- Event: SendCommand
- Region: us-east-1
- Assumed role: vulnlab-github-deploy
- Role session: github-38086693024-1
- SSM document: vulnlab-deploy
- Document version: 2
- Target instance: i-0c1ef48c9959fa2eb
- API error: None recorded

The role session connects the AWS request to the specific GitHub Actions run. The document and instance match the respetive deployment target. CloudTrail provides evidence of the API request and caller.

## Limitations

The controlled test demonstrates the detection path for failed logins. There are no detection features for every other security attack.

Events may be lost if delivery is interrupted / the buffer fills.
