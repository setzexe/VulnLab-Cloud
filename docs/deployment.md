# Manual application deployment

## Status

The remediated VulnLab app is deployed to EC2 using Docker Compose. The app responds to its health check.

Deployment is currently manual. Automated deployment is planned for Card 8.

## Design

Terraform manages the EC2 host, ECR repository, and host permissions. The configuration of the container is in deploy/compose.yaml.

The app image is built for linux/amd64, published to ECR, and selected by digest. ECR uses immutable tags and scan-on-push. The EC2 role can authenticate to ECR and pull images from the VulnLab repository. The app repository permissions do not include pushing or deleting images.

The app publishes port 5000 on the host's loopback. Redis does not have a published host port. Browser access uses Session Manager
port forwarding; the security group has no inbound rules.

The app runs as a non root user.

## Host files

- `/opt/vulnlab/compose.yaml`: Container configuration.
- `/opt/vulnlab/config-revision.txt`: Cloud repository revision used for deployment.
- `/opt/vulnlab/release.env`: Application and Redis image references.
- `/etc/vulnlab/runtime.env`: Application secret, owned by root with mode 0600.

The secret is generated on the host and kept outside Git and container images. It should be preserved when replacing containers.

Application data uses the vulnlab-data named volume. Redis uses redis-data with an every second fsync policy.

## Release

Application source revision:

```text
7c52ea2ef129180cfa671214a918b6e4ba864f9e
```

Published application digest:

```text
sha256:9245decac1072f8633a3bb41cdfdd0168efaf11ef2f87818bdf94400acede1f9
```

The complete app and Redis image references are recorded in
/opt/vulnlab/release.env.

## Verification

The local container test suite passes all 20 tests.

On EC2, the application returned {"status":"ok"}. Browser testing confirmed that a test note remained after container replacement.

To look at container health and check application-to-Redis connectivity:

```bash
cd /opt/vulnlab
sudo docker compose --env-file release.env ps

sudo docker compose --env-file release.env exec -T vulnlab \
  python -c 'import os, redis; print(redis.Redis.from_url(os.environ["VULNLAB_RATELIMIT_STORAGE_URI"]).ping())'
```

Expected results: both containers are healthy. Redis returns True.

## Browser access

Run from the VulnLab-Cloud repository root on the local machine:

```bash
HOST_ID=$(terraform -chdir=infra output -raw host_instance_id)

aws ssm start-session \
  --target "$HOST_ID" \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["5000"],"localPortNumber":["8080"]}' \
  --profile vulnlab-dev \
  --region us-east-1
```

Keep the session open and visit `http://127.0.0.1:8080`. This requires the Session Manager plugin and permission to use the
port-forwarding document.

## Cost and lifecycle

Stop the EC2 instance when the lab is idle. EBS storage and ECR images remain allocated while the instance is stopped. Named volumes preserve data across container replacement. They are stored on the host's root disk, which is deleted when the instance is terminated.

Do not use docker compose down -v when preserving lab data.

The ECR repository has force_delete disabled. Final teardown requires intentionally removing its images before Terraform can delete the repository.
