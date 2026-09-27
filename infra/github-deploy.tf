resource "aws_ssm_document" "deploy" {
  name            = "vulnlab-deploy"
  document_type   = "Command"
  document_format = "YAML"

  content = file("${path.module}/../deploy/ssm-deploy.yaml")
}

data "aws_iam_policy_document" "github_deployment" {
  statement {
    sid       = "AuthenticateToECR"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }

  statement {
    sid = "PublishVulnLabImages"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
    ]

    resources = [aws_ecr_repository.app.arn]
  }

  statement {
    sid     = "DeployToVulnLabHost"
    actions = ["ssm:SendCommand"]

    resources = [
      aws_ssm_document.deploy.arn,
      aws_instance.host.arn,
    ]
  }

  statement {
    sid = "ReadDeploymentStatus"

    actions = [
      "ssm:GetCommandInvocation",
      "ssm:DescribeInstanceInformation",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }
}

resource "aws_iam_role_policy" "github_deployment" {
  name   = "vulnlab-github-deployment"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deployment.json
}