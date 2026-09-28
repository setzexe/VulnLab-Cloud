# Automated deployment

## Status

GitHub Actions deploys the remediated application to the existing EC2 host. Pull requests build, test, and scan the selected application revision. A manually dispatched run from main also publishes the checked image to ECR and deploys it through Systems Manager.

The first automated deployment passed its health checks. Browser testing confirmed that the existing account and note survived through deployment.

## Design

Terraform defines the GitHub identity provider and the
`vulnlab-github-deploy` role. The trust policy requires the AWS STS audience and the exact OIDC subject for the VulnLab-Cloud repository's main branch.

The GitHub role can publish images to the VulnLab ECR repository and apply the vulnlab-deploy SSM document on the designated EC2 host. It can also read the SSM information required to check host availability and command status. The verification workflow requests a 15-minute session (900 seconds).

Permanent AWS access keys are not stored in GitHub.

The trust condition applies to eligible jobs on main. Changes to workflows on main will require review.

## Verification

- Main branch: role check succeeded and returned the wanted AWS identity.
- Test branch: AWS rejected AssumeRoleWithWebIdentity.
- Infrastructure CI: formatting, validation, and security checks passed.

## Cost and lifecycle

Identity verification does not require starting EC2. The existing EC2 storage and ECR images remain allocated. GitHub Actions
usage follows the repository's applicable usage limits.

Terraform manages the deployment role and, when created by this project, the GitHub identity provider.

## Deployment pipeline

The workflow is defined in `.github/workflows/deploy.yml.`

The application source is pinned to a reviewed commit in setzexe/VulnLab. The build job has no AWS credentials. It builds a linux/amd64 image, runs pytest inside that image, and applies the Trivy vulnerability gate. The gate rejects HIGH and CRITICAL OS or library vulnerabilities with available fixes. Unfixed vulnerabilities are excluded from this gate.

The checked image is given to a separate deployment job. That job
verifies its image ID and source label, obtains temporary AWS credentials through OIDC, and publishes the image with a unique immutable tag.

Deployment uses the ECR digest and a specific SSM document version.
The workflow reports success only after SSM reports a successful execution.

The host retains its existing Compose configuration, Redis image, runtime secret, and data volumes.

## Release evidence

- [Successful workflow run]([docs/project-scope.md](https://github.com/setzexe/VulnLab-Cloud/actions/runs/36361280638))
- Application source revision: `7c52ea2ef129180cfa671214a918b6e4ba864f9e`
- Deployed application digest: `sha256:f382a213257e4656ace9c6d79868f2b749d1aee998e49d7e52fa32e284d1e04d`
- SSM document version: `2`

The running container image reference matched both the workflow summary and `/opt/vulnlab/release.env.`

## Recovery boundaries

If candidate startup or verification fails, the deployment document
attempts to restore the previous application image. The workflow reports failure even when restoration succeeds.

This recovery path is implemented but has not yet been
properly tested for failure. It does not restore database contents or reverse schema changes.

## Operation

Start EC2 and wait for SSM to report Online before dispatching the workflow from main. Stop EC2 after completing the session.

Future application releases require updating APP_REV to a reviewed,
remediated application commit. Future document regarding deployment changes require applying Terraform and updating the workflow's document version.
